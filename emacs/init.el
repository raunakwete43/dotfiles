;;; init.el --- Basic Emacs Configuration

;; -----------------------------------------
;; 1. Clean up the User Interface
;; -----------------------------------------
(setq inhibit-startup-message t)    ; Disable the default splash screen
(scroll-bar-mode -1)                ; Disable the visual scrollbar
(tool-bar-mode -1)                  ; Disable the clunky toolbar at the top
(tooltip-mode -1)                   ; Disable tooltips
(menu-bar-mode -1)                  ; Disable the menu bar (keeps screen clean)

;; -----------------------------------------
;; 2. Quality of Life Defaults
;; -----------------------------------------
(setq visible-bell t)               ; Flash screen instead of a system beep on errors
(defalias 'yes-or-no-p 'y-or-n-p)   ; Type 'y' or 'n' instead of typing out 'yes' or 'no'
(global-auto-revert-mode t)         ; Automatically update buffers if the file changes on disk
(save-place-mode 1)                 ; Remember your cursor position when you reopen a file
(recentf-mode 1)                    ; Keep track of recently opened files

;; -----------------------------------------
;; 3. Text Editing Enhancements
;; -----------------------------------------
(global-display-line-numbers-mode t); Show line numbers globally
(setq-default indent-tabs-mode nil) ; Strictly use spaces instead of tabs
(show-paren-mode 1)                 ; Highlight the matching parenthesis
(electric-pair-mode 1)              ; Automatically close quotes and parentheses

;; -----------------------------------------
;; 4. Visuals (Built-in Theme)
;; -----------------------------------------
;; Emacs 28+ comes with the excellent, accessible 'modus' themes.
;; 'modus-vivendi' is dark mode, 'modus-operandi' is light mode.
(load-theme 'modus-vivendi t)
