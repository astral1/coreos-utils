#!/usr/bin/env bash

command -v brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

command -v corectl || (brew update && brew install corectl)
command -v fleetctl || (brew update && brew install fleetctl)
