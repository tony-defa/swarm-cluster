## HA backup
add to `configuration.yml`
```yml
shell_command:
  move_and_rename_backup: /bin/bash /config/shell_scripts/manage_backups.sh
```
then 
```sh
sudo mkdir shell_scripts
```
create file `manage_backups.sh` in shell_scripts containing the following:
```sh
#!/bin/bash

# Define variables
HA_SOURCE_DIR="/config/backups"
HA_FILENAME_PREFIX="ha_backup_"
TARGET_DIR="/backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
TARGET_FILE="${HA_FILENAME_PREFIX}${DATE}.tar"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Find the latest backup file
LATEST_BACKUP=$(ls -t "$HA_SOURCE_DIR"/*.tar | head -n 1)

# Move and rename the latest backup
if [ -f "$LATEST_BACKUP" ]; then
  mv "$LATEST_BACKUP" "$TARGET_DIR/$TARGET_FILE"
else
  echo "No backup file found in $HA_SOURCE_DIR."
  exit 1
fi

# Delete old backups, keeping only the latest 14
cd "$TARGET_DIR" || exit 1
ls -t | tail -n +15 | xargs -I {} rm -- {}
```

