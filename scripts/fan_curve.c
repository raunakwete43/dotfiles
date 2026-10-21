// fanctl.c - ASUS EC fan curve daemon with external config
// Build: gcc -O2 -Wall -Wextra -o fanctl fanctl.c
// Usage: sudo ./fanctl run [-v] [-c config] [-p profile] | set <percent> | auto
#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/io.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>

#define DEFAULT_CONFIG "/etc/fanctl.conf"
#define MAX_POINTS 32
#define MAX_FAILS 5

/* ---------------- Config ---------------- */

typedef struct {
  int temp, pct;
} point_t;

typedef struct {
  int poll_ms, refresh_s, hysteresis, crit_temp;
  int max_percent, idle_pct, fan_count;
  char profile[32];
  point_t pts[MAX_POINTS];
  int npts;
} config_t;

static config_t cfg;

static void config_defaults(config_t *c) {
  memset(c, 0, sizeof *c);
  c->poll_ms = 1000;
  c->refresh_s = 10;
  c->hysteresis = 5;
  c->crit_temp = 92;
  c->max_percent = 95;
  c->idle_pct = 0;
  c->fan_count = 2;
  snprintf(c->profile, sizeof c->profile, "balanced");
}

static int set_int(const char *key, const char *val, const char *want, int *dst,
                   int lo, int hi, int lineno) {
  if (strcmp(key, want))
    return 0;
  char *end;
  long v = strtol(val, &end, 10);
  if (*end || v < lo || v > hi) {
    fprintf(stderr, "config line %d: %s must be %d..%d\n", lineno, key, lo, hi);
    return -1;
  }
  *dst = (int)v;
  return 1;
}

/* Returns 0 on success. Only the selected profile's points are loaded. */
static int load_config(const char *path, const char *override, config_t *c) {
  FILE *f = fopen(path, "r");
  if (!f) {
    fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
    return -1;
  }
  config_defaults(c);
  if (override)
    snprintf(c->profile, sizeof c->profile, "%s", override);

  char line[256];
  int lineno = 0, in_section = 0, active = 0, found = 0, bad = 0;

  while (fgets(line, sizeof line, f)) {
    lineno++;
    char *s = line, *h = strchr(s, '#');
    if (h)
      *h = 0;
    while (isspace((unsigned char)*s))
      s++;
    size_t n = strlen(s);
    while (n && isspace((unsigned char)s[n - 1]))
      s[--n] = 0;
    if (!n)
      continue;

    if (*s == '[') {
      char *e = strchr(s, ']');
      if (!e) {
        fprintf(stderr, "config line %d: missing ]\n", lineno);
        bad = 1;
        break;
      }
      *e = 0;
      in_section = 1;
      active = !strcmp(s + 1, c->profile);
      if (active)
        found = 1;
      continue;
    }

    if (!in_section) { /* global key = value */
      char key[32], val[64];
      if (sscanf(s, "%31[^= \t] = %63s", key, val) != 2) {
        fprintf(stderr, "config line %d: expected key = value\n", lineno);
        bad = 1;
        break;
      }
      if (!strcmp(key, "profile")) {
        if (!override)
          snprintf(c->profile, sizeof c->profile, "%s", val);
        continue;
      }
      int r = set_int(key, val, "poll_ms", &c->poll_ms, 100, 60000, lineno);
      if (!r)
        r = set_int(key, val, "refresh_s", &c->refresh_s, 1, 3600, lineno);
      if (!r)
        r = set_int(key, val, "hysteresis", &c->hysteresis, 0, 30, lineno);
      if (!r)
        r = set_int(key, val, "crit_temp", &c->crit_temp, 40, 120, lineno);
      if (!r)
        r = set_int(key, val, "max_percent", &c->max_percent, 0, 100, lineno);
      if (!r)
        r = set_int(key, val, "idle_percent", &c->idle_pct, 0, 100, lineno);
      if (!r)
        r = set_int(key, val, "fan_count", &c->fan_count, 1, 2, lineno);
      if (!r)
        fprintf(stderr, "config line %d: unknown key '%s'\n", lineno, key);
      if (r <= 0) {
        bad = 1;
        break;
      }
      continue;
    }

    if (!active)
      continue; /* point in another profile */

    for (char *p = s; *p; p++)
      if (*p == ':')
        *p = ' ';
    int t, pct;
    if (sscanf(s, "%d %d", &t, &pct) != 2 || pct < 0 || pct > 100) {
      fprintf(stderr, "config line %d: expected \"temp percent\"\n", lineno);
      bad = 1;
      break;
    }
    if (c->npts >= MAX_POINTS) {
      fprintf(stderr, "config line %d: too many points (max %d)\n", lineno,
              MAX_POINTS);
      bad = 1;
      break;
    }
    if (c->npts && t <= c->pts[c->npts - 1].temp) {
      fprintf(stderr, "config line %d: temps must be strictly ascending\n",
              lineno);
      bad = 1;
      break;
    }
    c->pts[c->npts++] = (point_t){t, pct};
  }
  fclose(f);
  if (bad)
    return -1;

  if (!found) {
    fprintf(stderr, "profile '%s' not found in %s\n", c->profile, path);
    return -1;
  }
  if (!c->npts) {
    fprintf(stderr, "profile '%s' has no points\n", c->profile);
    return -1;
  }
  return 0;
}

/* ---------------- EC low level ---------------- */

#define EC_DATA 0x25C
#define EC_CMD 0x25D
#define EC_OBF 0x01
#define EC_IBF 0x02
#define EC_TIMEOUT 1000
#define ASUS_EC_COMMAND 0xDD
#define HT_PREFIX 0x82
#define HT_TEST_MODE 0x31
#define HT_FAN_INDEX 0x32
#define HT_FAN_PWM 0x35

static void sleep_100us(void) {
  struct timespec ts = {0, 100000L};
  nanosleep(&ts, NULL);
}

static int wait_ibf_clear(void) {
  for (int i = 0; i < 200; i++)
    if (!(inb(EC_CMD) & EC_IBF))
      return 0;
  for (int i = 0; i < EC_TIMEOUT; i++) {
    sleep_100us();
    if (!(inb(EC_CMD) & EC_IBF))
      return 0;
  }
  return -ETIMEDOUT;
}

static int drain_output(void) {
  if (!(inb(EC_CMD) & EC_OBF))
    return 0;
  for (int i = 0; i < EC_TIMEOUT; i++) {
    (void)inb(EC_DATA);
    if (!(inb(EC_CMD) & EC_OBF))
      return 0;
    sleep_100us();
  }
  return -ETIMEDOUT;
}

static int ec_cmd(uint8_t v) {
  int r = wait_ibf_clear();
  if (r)
    return r;
  outb(v, EC_CMD);
  return 0;
}
static int ec_data(uint8_t v) {
  int r = wait_ibf_clear();
  if (r)
    return r;
  outb(v, EC_DATA);
  return 0;
}

static int ec_write(uint8_t command, const uint8_t *p, size_t len) {
  int r;
  if ((r = drain_output()))
    return r;
  if ((r = ec_cmd(0xFF)))
    return r;
  if ((r = ec_cmd(command)))
    return r;
  for (size_t i = 0; i < len; i++)
    if ((r = ec_data(p[i])))
      return r;
  return wait_ibf_clear();
}

static int ht_write(uint8_t reg, uint8_t val) {
  const uint8_t p[] = {HT_PREFIX, reg, val};
  return ec_write(ASUS_EC_COMMAND, p, sizeof p);
}

/* ---------------- Cached EC state ---------------- */

static int g_test_mode = 0;
static int g_index = -1;

static int select_fan(int idx) {
  if (g_index == idx)
    return 0;
  int r = ht_write(HT_FAN_INDEX, (uint8_t)idx);
  if (!r)
    g_index = idx;
  return r;
}

static int ec_set_percent(unsigned pct) {
  int r;
  if (pct > (unsigned)cfg.max_percent)
    pct = (unsigned)cfg.max_percent;
  uint8_t pwm = (uint8_t)((pct * 255U + 50U) / 100U);

  if (!g_test_mode) {
    if ((r = select_fan(0)))
      return r;
    if ((r = ht_write(HT_TEST_MODE, 1)))
      return r;
    g_test_mode = 1;
  }
  int start = g_index < 0 ? 0 : g_index;
  for (int k = 0; k < cfg.fan_count; k++) {
    int fan = (start + k) % cfg.fan_count;
    if ((r = select_fan(fan)))
      return r;
    if ((r = ht_write(HT_FAN_PWM, pwm)))
      return r;
  }
  return 0;
}

static int ec_set_auto(void) {
  int r;
  if ((r = select_fan(0)))
    return r;
  if ((r = ht_write(HT_TEST_MODE, 0)))
    return r;
  g_test_mode = 0;
  return 0;
}

/* ---------------- Temperature ---------------- */

static int g_temp_fd = -1;

static int open_k10temp(void) {
  DIR *d = opendir("/sys/class/hwmon");
  if (!d)
    return -1;
  struct dirent *e;
  char path[320], name[64];
  while ((e = readdir(d))) {
    if (strncmp(e->d_name, "hwmon", 5))
      continue;
    snprintf(path, sizeof path, "/sys/class/hwmon/%s/name", e->d_name);
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0)
      continue;
    ssize_t n = read(fd, name, sizeof name - 1);
    close(fd);
    if (n <= 0)
      continue;
    name[n] = 0;
    if (strncmp(name, "k10temp", 7))
      continue;
    snprintf(path, sizeof path, "/sys/class/hwmon/%s/temp1_input", e->d_name);
    g_temp_fd = open(path, O_RDONLY | O_CLOEXEC);
    if (g_temp_fd >= 0) {
      closedir(d);
      return 0;
    }
  }
  closedir(d);
  return -1;
}

static int read_temp(void) {
  char buf[16];
  ssize_t n = pread(g_temp_fd, buf, sizeof buf - 1, 0);
  if (n <= 0)
    return -1;
  buf[n] = 0;
  char *end;
  long v = strtol(buf, &end, 10);
  if (end == buf || v < 0)
    return -1;
  return (int)(v / 1000);
}

/* ---------------- Curve with hysteresis ---------------- */

static int g_level = -2; /* -2 = uninitialised, -1 = below first point */

static int curve_percent(int temp) {
  if (g_level == -2) {
    g_level = -1;
    for (int i = 0; i < cfg.npts && temp >= cfg.pts[i].temp; i++)
      g_level = i;
  } else {
    while (g_level < cfg.npts - 1 && temp >= cfg.pts[g_level + 1].temp)
      g_level++;
    while (g_level >= 0 && temp <= cfg.pts[g_level].temp - cfg.hysteresis)
      g_level--;
  }
  return g_level < 0 ? cfg.idle_pct : cfg.pts[g_level].pct;
}

/* ---------------- Daemon ---------------- */

static volatile sig_atomic_t g_run = 1, g_reload = 0;
static void on_term(int s) {
  (void)s;
  g_run = 0;
}
static void on_hup(int s) {
  (void)s;
  g_reload = 1;
}

static void add_ms(struct timespec *t, long ms) {
  t->tv_sec += ms / 1000;
  t->tv_nsec += (ms % 1000) * 1000000L;
  if (t->tv_nsec >= 1000000000L) {
    t->tv_nsec -= 1000000000L;
    t->tv_sec++;
  }
}

static int run(const char *path, const char *profile, int verbose) {
  if (load_config(path, profile, &cfg))
    return 1;
  if (open_k10temp()) {
    fprintf(stderr, "k10temp sensor not found\n");
    return 1;
  }

  struct sigaction sa = {0};
  sa.sa_handler = on_term; /* no SA_RESTART: interrupts sleep */
  sigaction(SIGINT, &sa, NULL);
  sigaction(SIGTERM, &sa, NULL);
  sa.sa_handler = on_hup;
  sigaction(SIGHUP, &sa, NULL);
  mlockall(MCL_CURRENT | MCL_FUTURE);

  fprintf(stderr, "profile '%s', %d points, poll %d ms\n", cfg.profile,
          cfg.npts, cfg.poll_ms);

  int cur_pct = -1, fails = 0, firmware = 0;
  struct timespec next, last_write = {0, 0}, now;
  clock_gettime(CLOCK_MONOTONIC, &next);

  while (g_run) {
    if (g_reload) {
      g_reload = 0;
      config_t tmp;
      if (!load_config(path, profile, &tmp)) {
        cfg = tmp;
        g_level = -2;
        cur_pct = -1; /* force a write with the new curve */
        fprintf(stderr, "config reloaded: profile '%s', %d points\n",
                cfg.profile, cfg.npts);
      } else {
        fprintf(stderr, "reload failed, keeping previous config\n");
      }
    }

    int temp = read_temp();
    if (temp < 0) {
      fprintf(stderr, "temperature read failed\n");
      if (++fails >= MAX_FAILS)
        break;
    } else {
      int pct = curve_percent(temp); /* always track the level */
      int crit = temp >= cfg.crit_temp ||
                 (firmware && temp > cfg.crit_temp - cfg.hysteresis);

      clock_gettime(CLOCK_MONOTONIC, &now);
      int stale = (now.tv_sec - last_write.tv_sec) >= cfg.refresh_s;
      int rc = 0;

      if (crit) {
        if (!firmware || stale) {
          rc = ec_set_auto();
          if (!rc) {
            firmware = 1;
            cur_pct = -1;
            last_write = now;
            fprintf(stderr, "%d C: critical, firmware control\n", temp);
          }
        }
      } else if (pct != cur_pct || firmware || stale) {
        rc = ec_set_percent((unsigned)pct);
        if (!rc) {
          if (verbose && (pct != cur_pct || firmware))
            printf("%d C -> %d%%\n", temp, pct), fflush(stdout);
          cur_pct = pct;
          firmware = 0;
          last_write = now;
        }
      }

      if (rc) {
        fprintf(stderr, "EC write failed: %d\n", rc);
        if (++fails >= MAX_FAILS)
          break;
      } else {
        fails = 0;
      }
    }

    add_ms(&next, cfg.poll_ms);
    while (g_run && !g_reload &&
           clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next, NULL) ==
               EINTR)
      ;
  }

  if (ec_set_auto())
    fprintf(stderr, "WARNING: failed to restore auto control!\n");
  else if (verbose)
    puts("auto control restored");
  return fails >= MAX_FAILS ? 1 : 0;
}

static int usage(const char *prog) {
  fprintf(stderr,
          "usage: sudo %s run [-v] [-c config] [-p profile]\n"
          "       sudo %s set <percent>\n"
          "       sudo %s auto\n"
          "default config: " DEFAULT_CONFIG "\n"
          "send SIGHUP to a running daemon to reload the config\n",
          prog, prog, prog);
  return 1;
}

int main(int argc, char **argv) {
  if (argc < 2)
    return usage(argv[0]);
  config_defaults(&cfg);
  if (ioperm(EC_DATA, 2, 1)) {
    perror("ioperm (need root)");
    return 1;
  }

  int rc = 1;
  if (!strcmp(argv[1], "run")) {
    const char *path = DEFAULT_CONFIG, *profile = NULL;
    int verbose = 0;
    for (int i = 2; i < argc; i++) {
      if (!strcmp(argv[i], "-v"))
        verbose = 1;
      else if (!strcmp(argv[i], "-c") && i + 1 < argc)
        path = argv[++i];
      else if (!strcmp(argv[i], "-p") && i + 1 < argc)
        profile = argv[++i];
      else
        return usage(argv[0]);
    }
    rc = run(path, profile, verbose);
  } else if (!strcmp(argv[1], "auto")) {
    rc = ec_set_auto() ? 1 : 0;
  } else if (!strcmp(argv[1], "set") && argc == 3) {
    char *end;
    long p = strtol(argv[2], &end, 10);
    if (*end || p < 0) {
      fprintf(stderr, "bad percentage\n");
      return 1;
    }
    rc = ec_set_percent((unsigned)p) ? 1 : 0;
  } else {
    return usage(argv[0]);
  }

  ioperm(EC_DATA, 2, 0);
  return rc;
}
