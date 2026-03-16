#!/bin/bash

# Symlink 10-wakeup.rules to /etc/udev/rules.d/
sudo ln -sf "$(pwd)/10-wakeup.rules" /etc/udev/rules.d/10-wakeup.rules

echo "Symlink created: /etc/udev/rules.d/10-wakeup.rules"