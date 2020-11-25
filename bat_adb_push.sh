#!/bin/bash

shell_dir=$(dirname "$0")
"$shell_dir"/.batch_devices.sh --stat device push "$*"