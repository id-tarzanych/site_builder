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
notification "Checking if Drupal was previously built..."
DRUPAL_STATUS=$(drush status | grep "Drupal version"  | tr -d '[[:space:]]')
if [ ${#DRUPAL_STATUS} != 0 ];
then
  VERSION=$(echo -e "$DRUPAL_STATUS" | rev | cut -d":" -f1 | rev | tr -d '[[:space:]]')
  warning "Drupal $VERSION found."

  read -p "This will drop your current Drupal installation. Do you want to continue? " yn
  case $yn in
    [Yy]* ) warning "Dropping database...\n\n"; drush sql-drop -y;;
    [Nn]* ) error "Installation aborted."; exit;;
    * ) echo "Please answer yes or no.";;
  esac
else
  success "No existing Drupal site found.\n\n"
fi

success "#####################################"
success "########## Installing site ##########"
success "#####################################"

# Building Drupal from Drush Make file.
chmod -R 755 sites/default
drush make "$global_machine_name.make.yml" -y

# Installing Drupal.
notification "Installing site..."
sqlfile=$path/build/dump/$global_machine_name.sql
gzipped_sqlfile=$sqlfile.gz
if [ -e "$gzipped_sqlfile" ]; then
  notification "...from reference database."
  drush sql-drop -y
  zcat "$gzipped_sqlfile" | drush sqlc
elif [ -e "$sqlfile" ]; then
  notification "...from reference database."
  drush sql-drop -y
  drush sqlc < $sqlfile
else
  notification "...from scratch, with Drupal minimal profile.";
  # Setting PHP Options so that we don't fail while sending mail if a mail
  # system doesn't exist.
  PHP_OPTIONS="-d sendmail_path=`which true`" drush si minimal --account-name=admin --account-pass=p@ssw@rd --account-mail=$global_site_mail --site-name="$global_project_name" --db-url=mysql://$db_user:$db_password@$db_host:$db_port/$db_database -y
fi

notification "Resolving dependencies..."
drush en $global_machine_name -y

notification "Enabling site theme..."
drush en $global_site_theme -y
drush vset theme_default $global_site_theme

notification "Enabling admin theme..."
drush en $global_admin_theme -y
drush vset admin_theme $global_admin_theme

# Restoring .gitignore
git checkout .gitignore

success "\n${GREEN}$global_project_name${LIGHTGREEN} site installed successfully."
success "Administrator user: ${GREEN}admin${LIGHTGREEN} Password: ${GREEN}p@ssw@rd${LIGHTGREEN}"
