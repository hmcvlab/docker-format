"""
Created on Wed Nov 15 2023
Copyright (c) 2023 Munich University of Applied Sciences
"""
import argparse
import pathlib
import platform
import re

import git
import pandas as pd
from termcolor import colored

# Global constants
ROOT = pathlib.Path(git.Repo().git.rev_parse("--show-toplevel"))
TAG = ROOT.joinpath("vars/tag").read_text(encoding="utf-8").strip()
URL = ROOT.joinpath("vars/url").read_text(encoding="utf-8").strip()


def match(pattern: str, string: str) -> bool:
    """Function which matches a pattern in a string"""
    matching_str = "".join(re.compile(pattern).findall(string))

    # Highlight all characters which are not matching red in string
    highlighted_str = ""
    for char in string:
        highlighted_str += char if char in matching_str else colored(char, "red")
    print_status(
        f"Disallowed characters highlighted red: {highlighted_str}",
        matching_str == string,
    )
    return matching_str == string


def verify_options(image_database: pd.DataFrame, args: argparse.Namespace, arch: str):
    """Print the verification process"""
    # Print arguments
    print("=" * 100)
    print(f"Arguments:\n{args}")
    print("-" * 100)

    # Check if URL and TAG are valid
    match(r"[a-z0-9/:.\-]+", URL)
    match(r"[0-9.]+", TAG)
    print("-" * 100)

    # Print image data base
    print(image_database)
    print("-" * 100)

    # Check if base image name is in image_database
    index = f"{arch}-{args.ros}"
    print_status(
        f"Base image {index} is in image_database?",
        index in list(image_database.index),
    )
    print("-" * 100)

    # Extract row where args.base is equal to index
    print(f"Image database:\n{image_database.loc[index]}")
    print("-" * 100)
    build_args = args
    build_args.context = "build"
    print("Build options:")
    options(image_database, build_args, arch)
    print("-" * 100)
    push_args = args
    push_args.context = "push"
    print("Push options:")
    options(image_database, push_args, arch)
    print("=" * 100)


def print_status(msg: str, is_true: bool, is_critical=True) -> None:
    """Function which prints a message with OK for true and ERROR for false"""
    if is_critical and not is_true:
        # print red error
        print("\033[91m" + "ERROR" + "\033[0m" + ": " + msg)
        raise SystemExit(1)  # exit with error code 1 if critical error

    if not is_true:
        # print yellow warning
        print("\033[93m" + "WARNING" + "\033[0m" + ": " + msg)
    else:
        # print green ok
        print("\033[92m" + "OK" + "\033[0m" + ": " + msg)


def options(image_database: pd.DataFrame, args: argparse.Namespace, arch: str):
    """Extracting docker build/push/test options from image_database"""

    # Generate build options
    if args.context == "build":
        # Extract row where args.base is equal to index
        row = image_database.loc[f"{arch}-{args.ros}"]
        options_list = [
            "--pull",
            "--label maintainer=messtechnik-labor",
            "--build-arg CATKIN_WS=/root/catkin_ws",
            f"--build-arg ROS_DISTRO={args.ros}",
            f"--build-arg BASE_IMAGE={row['image']}",
            f"--build-arg UBUNTU_VERSION={row['ubuntu_version']}",
            f"--file {ROOT.absolute()}/dockerfiles/{arch}.Dockerfile",
            "--target final",
            "--tag",
        ]

    elif args.context == "push":
        options_list = []
    print(" ".join(options_list + [f"{URL}/tmp:{arch}-{args.ros}-{TAG}"]))


def main():
    """Main"""

    # Handle input arguments
    parser = argparse.ArgumentParser("Script to build docker containers")
    parser.add_argument(
        "--ros",
        type=str,
        required=False,
        choices=["foxy", "humble", "rolling", "iron"],
    )
    parser.add_argument(
        "--context",
        type=str,
        required=True,
        choices=["build", "push", "verify"],
    )
    args = parser.parse_args()

    # Extract architecture
    architecture = {"x86_64": "amd", "aarch64": "arm"}[platform.machine()]

    # Load image database via pandas
    image_database_path = ROOT / "config" / "image_database.csv"
    image_database = pd.read_csv(image_database_path, index_col=0)

    # Build docker image
    if args.context == "verify":
        verify_options(image_database, args, architecture)
    else:
        options(image_database, args, architecture)


if __name__ == "__main__":
    main()
