#!/usr/bin/env bash
sudo pacman -Sy ansible --noconfirm
ansible-playbook local.yml -J -K
