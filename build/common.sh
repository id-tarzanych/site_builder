#!/bin/bash

source $path/colors.sh

function notification {
    printf "${BOLD}${WHITE}$1${NC}\n"
}

function success {
    printf "${BOLD}${LIGHTGREEN}$1${NC}\n"
}

function error {
    printf "${BOLD}${LIGHTRED}$1${NC}\n"
}

function warning {
    printf "${BOLD}${YELLOW}$1${NC}\n"
}
