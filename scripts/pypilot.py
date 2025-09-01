import requests
import click
from bs4 import BeautifulSoup
import importlib.metadata as metadata
import subprocess
import sys


def show_python_environment():
    python_version = sys.version
    python_path = sys.executable
    click.echo(click.style("Python Version: ", fg='blue',
               bold=True) + click.style(python_version, fg='green'))
    click.echo(click.style("Python Path: ", fg='blue', bold=True) +
               click.style(python_path, fg='red'))
    print("\n")


def install_package(package_name):
    try:
        # Use subprocess to execute the pip install command
        print("\n")
        cmd = f"pip install {package_name}"
        click.echo(f"{click.style(cmd, fg='yellow')}")
        print("\n")
        subprocess.check_call(['pip', 'install'] + package_name.split())
    except subprocess.CalledProcessError as e:
        print(f"Error installing {package_name}: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")


@click.command()
@click.argument('name')
@click.option('--pages', default=1, help='Number of pages to search (default: 1)')
def search_packages(name, pages):
    name = name.replace(" ", "")
    URL = f"https://pypi.org/search/?q={name}&o="
    request = requests.get(url=URL)
    soup = BeautifulSoup(request.content, "html.parser")

    total_results = soup.find("strong").text

    try:
        total_pages = (int(total_results) // 20)
    except ValueError:
        total_pages = 500

    if (pages > total_pages):
        msg1 = "Input pages exceed the limit of total pages available!!"
        msg2 = f"Total pages avilable = {total_pages}"
        msg3 = "Using the default number of pages i.e 1"
        click.echo(f"{click.style(msg1, fg='red', bold=True, italic=True)}")
        click.echo(f"{click.style(msg2, fg='yellow', bold=True)}")
        click.echo(f"{click.style(msg3, fg='magenta', bold=True)}")
        pages = 1

    title = []
    version = []
    description = []

    for page in range(1, pages + 1):
        URL = f"https://pypi.org/search/?o=&q={name}&page={page}"
        new_request = requests.get(url=URL)
        new_soup = BeautifulSoup(new_request.content, "html.parser")

        # Parse data from the current page
        names = new_soup.find_all(
            "span", attrs={"class": "package-snippet__name"})
        vers = new_soup.find_all(
            "span", attrs={"class": "package-snippet__version"})
        des = new_soup.find_all(
            "p", attrs={"class": "package-snippet__description"})

        # Check if the lists have the same length after appending
        if len(names) == len(vers) == len(des):
            title += [name.text for name in names]
            version += [ver.text for ver in vers]
            description += [descr.text for descr in des]
        else:
            print(f"Warning: Inconsistent data on page {page}")

    installed_packages = [pkg for pkg in metadata.packages_distributions()]

    for index, (pkg_title, pkg_version, pkg_description) in reversed(list(enumerate(zip(title, version, description), start=1))):
        if (pkg_title.lower() in installed_packages):
            msg = click.style(str(index), fg='blue', bold=True) + click.style(". Name: ") + click.style(
                pkg_title, fg='green', bold=True) + click.style(" (Installed)", fg='cyan', bold=True)
            click.echo(msg)
        else:
            click.echo(
                f"{click.style(str(index), fg='blue', bold=True)}. Name: {click.style(pkg_title, fg='green', bold=True)}")
        click.echo(f"   Version: {pkg_version}")
        click.echo(
            f"   Description: {click.style(pkg_description, italic=True)}\n")

    show_python_environment()

    prompt = click.style("==> ", fg='green', bold=True) + \
        "Select the package to install (eg: 1 2 3)"
    click.echo(prompt)
    indexes = input(click.style("==> ", fg='green', bold=True))
    selected_index = [(int(idx) - 1) for idx in indexes.split()]
    selected_names = [title[i] for i in selected_index if 0 <= i < len(title)]
    result_string = " ".join(selected_names)
    install_package(result_string)


print("\n")
search_packages()
