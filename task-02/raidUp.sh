#!/bin/bash

mdadm --zero-superblock --force /dev/sd{b,c,d,e}
mdadm --create /dev/md0 --level=5 --raid-devices=4 /dev/sd{b,c,d,e}