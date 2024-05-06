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
echo "Dolibarr main data root: ${config[dolibarr_main_data_root]}"
echo "Dolibarr main database host: ${config[dolibarr_main_db_host]}"
echo "Dolibarr main database port: ${config[dolibarr_main_db_port]}"
echo "Dolibarr main database name: ${config[dolibarr_main_db_name]}"
echo "Dolibarr main database user: ${config[dolibarr_main_db_user]}"
echo "Dolibarr main database password: ${config[dolibarr_main_db_pass]}"

# Variables
DOLIBARR_DIR="${config[dolibarr_main_document_root]}"
DOLIBARR_DATA_DIR="${config[dolibarr_main_data_root]}"
BACKUP_DIR="${DOLIBARR_DIR}_backup"

echo "Creating backup directory..."
mkdir -p ${BACKUP_DIR}

echo "Creating a backup of the current Dolibarr installation..."
backup_file="${BACKUP_DIR}/dolibarr_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
(cd "$(dirname "${DOLIBARR_DIR}")" && tar -czvf "${backup_file}" "$(basename "${DOLIBARR_DIR}")")

echo "Creating a backup of the Documents Folder..."
backup_file="${BACKUP_DIR}/dolibarr_backup_documents_$(date +%Y%m%d_%H%M%S).tar.gz"
(cd "$(dirname "${DOLIBARR_DATA_DIR}")" && tar -czvf "${backup_file}" "$(basename "${DOLIBARR_DATA_DIR}")")

echo "Backing up the Dolibarr database..."
db_backup_file="${BACKUP_DIR}/dolibarr_db_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
mysqldump -h ${config[dolibarr_main_db_host]} -P ${config[dolibarr_main_db_port]} -u ${config[dolibarr_main_db_user]} -p${config[dolibarr_main_db_pass]} ${config[dolibarr_main_db_name]} | gzip > "${db_backup_file}"

# Check if backups are created successfully and not empty
if [ -s "${backup_file}" ] && [ -s "${db_backup_file}" ]; then
    echo "Backups created successfully."
    exit 1
else
    echo "Backup creation failed or backup files are empty."
    exit 1
fi

