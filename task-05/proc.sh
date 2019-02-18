#!/usr/bin/env bash

PROC=/proc

ls -a $PROC | grep -o '[0-9]*' | sort -n
