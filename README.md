# Dolibarr ERP/CRM
Find some of our Dolibarr ERP/CRM related codework here

### update_dolibarr.sh
This is a Bash script that automates the update process for the Dolibarr ERP and CRM software. 

The script first reads the Dolibarr configuration file to retrieve important configuration variables, such as the root URL, document root, database host, port, name, user, and password. Then, it creates a backup directory and performs a backup of the current Dolibarr installation, including its files and database.
Next, the script downloads the latest Dolibarr release from GitHub, extracts it, and copies the new version files to the existing Dolibarr installation. If there is an install.lock file, it is removed to allow the upgrade process to complete. Finally, the script reports whether the upgrade process was successful and instructs the user to visit a URL to complete the upgrade process.

Usage: 
Add the script to your dolbarr-root (use /dolibarr not /dolibarr/htdocs)
chmod +x update_dolibarr.sh
./update_dolibarr.sh

It should perform everything fully automated. In case of issues, feel free to contact us!

