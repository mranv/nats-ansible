#!/bin/bash

# Run this script on each target host before running the Ansible playbook

# Update package lists
if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:deadsnakes/ppa
    apt-get update
    apt-get install -y python3.8 python3.8-venv python3-pip python3.8-distutils
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y python38 python38-devel python38-pip
fi

# Install pip and required packages
python3.8 -m pip install --upgrade pip
python3.8 -m pip install typing-extensions
