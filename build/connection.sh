#!/bin/bash

if [ -n "$1" ]; then
  ENVIRONMENT="$1"
  varname="env_${ENVIRONMENT}_database_database"
  if [ -z "${!varname}" ]; then
    error "${RED}$ENVIRONMENT${LIGHTRED} environment not found. Terminating build process.";
    exit;
  fi
  success "Using ${GREEN}$ENVIRONMENT${LIGHTGREEN} environment."
else
  ENVIRONMENT="development"
  warning "No environment selected, using ${ORANGE}development${YELLOW} as default value."
fi

for VARIABLE in "host" "port" "database" "user" "password"
do
    varname="env_${ENVIRONMENT}_database_${VARIABLE}"
    declare "db_$VARIABLE=${!varname}"
done
