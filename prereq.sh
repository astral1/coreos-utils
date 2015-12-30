#!/usr/bin/env bash

command -v brew &> /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

command -v corectl &> /dev/null || (brew update && brew install corectl)
command -v fleetctl &> /dev/null || (brew update && brew install fleetctl)
