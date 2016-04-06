#!/bin/bash

path=$(dirname "$0")
source $path/parse_yaml.sh
source $path/common.sh

# Read settings YAML file.
notification "Reading settings file..."
eval $(parse_yaml $path/../cnf/config.yml)

# Get environment variables.
notification "Parsing variables..."
source $path/connection.sh "$1"

# Changing working folder.
cd $path/..

# Check if Drupal was installed.
notification "Checking if Drupal is installed..."
DRUPAL_STATUS=$(drush status | grep "Drupal version")
if [ DRUPAL_STATUS == '' ];
then
  error "No existing Drupal site found.\n"
  exit
fi

notification "Updating site..."
chmod -R 755 sites/default
drush make "$global_machine_name.make.yml" -y

# Restoring .gitignore
git checkout .gitignore

drush drux-enable-dependencies -y
drush updatedb -y
drush fra -y
drush cc all

success "Update complete."
