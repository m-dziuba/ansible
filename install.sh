#!/usr/bin/env bash
sudo pacman -Sy ansible --noconfirm --needed
ansible-playbook local.yml -J -K
git remote set-url git@github.com:m-dziuba/ansible
