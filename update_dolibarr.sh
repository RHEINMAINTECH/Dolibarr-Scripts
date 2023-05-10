#!/bin/bash

# Read Dolibarr configuration
declare -A config
while read -r line; do
  if [[ $line =~ ^\$dolibarr_ ]]; then
    IFS="=" read -ra parts <<< "$line"
    key="${parts[0]#*$}"; key="${key%%\'*}"
    value="${parts[1]#*\'}"; value="${value%%\'*}"
    config["$key"]="$value"
  fi
done < htdocs/conf/conf.php

# Print Dolibarr configuration variables
echo "Dolibarr main URL root: ${config[dolibarr_main_url_root]}"
echo "Dolibarr main document root: ${config[dolibarr_main_document_root]}"
echo "Dolibarr main database host: ${config[dolibarr_main_db_host]}"
echo "Dolibarr main database port: ${config[dolibarr_main_db_port]}"
echo "Dolibarr main database name: ${config[dolibarr_main_db_name]}"
echo "Dolibarr main database user: ${config[dolibarr_main_db_user]}"
echo "Dolibarr main database password: ${config[dolibarr_main_db_pass]}"

# Variables
DOLIBARR_DIR="${config[dolibarr_main_document_root]}"
BACKUP_DIR="${DOLIBARR_DIR}_backup"
LATEST_URL="https://api.github.com/repos/Dolibarr/dolibarr/releases/latest"
#LATEST_URL="https://api.github.com/repos/Dolibarr/dolibarr/releases/tags/14.0.4"
#LATEST_URL="https://api.github.com/repos/Dolibarr/dolibarr/releases/tags/15.0.2"

echo "Creating backup directory..."
mkdir -p ${BACKUP_DIR}

echo "Creating a backup of the current Dolibarr installation..."
backup_file="${BACKUP_DIR}/dolibarr_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
(cd "$(dirname "${DOLIBARR_DIR}")" && tar -czvf "${backup_file}" "$(basename "${DOLIBARR_DIR}")")

echo "Backing up the Dolibarr database..."
db_backup_file="${BACKUP_DIR}/dolibarr_db_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
mysqldump -h ${config[dolibarr_main_db_host]} -P ${config[dolibarr_main_db_port]} -u ${config[dolibarr_main_db_user]} -p${config[dolibarr_main_db_pass]} ${config[dolibarr_main_db_name]} | gzip > "${db_backup_file}"

# Check if backups are created successfully and not empty
if [ -s "${backup_file}" ] && [ -s "${db_backup_file}" ]; then
    echo "Backups created successfully."
else
    echo "Backup creation failed or backup files are empty. Aborting the update process."
    exit 1
fi

echo "Downloading the latest Dolibarr release..."
RELEASE_URL=$(curl -s ${LATEST_URL} | grep 'tarball_url' | cut -d'"' -f4)
wget -O dolibarr_latest.tar.gz ${RELEASE_URL}

echo "Extracting the downloaded Dolibarr tar.gz file..."
mkdir -p dolibarr_new
tar -xzf dolibarr_latest.tar.gz -C dolibarr_new --strip-components=1

echo "Copying the new version files to the existing Dolibarr installation..."
rsync -a dolibarr_new/htdocs/ ${DOLIBARR_DIR}/

echo "Removing install.lock if it exists..."
rm -f ${config[dolibarr_main_data_root]}/install.lock

echo "Dolibarr update completed successfully. Please visit ${config[dolibarr_main_url_root]}/install to complete the upgrade process."
