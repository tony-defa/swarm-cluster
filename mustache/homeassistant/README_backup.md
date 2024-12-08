## HA & z2m backup
Backup is created automatically for z2m always at 4 am. But for home assistant an automation needs to be created manually

```yml
alias: Backup Home Assistant every night at 3:30 AM
trigger:
  - platform: time
    at: "03:30:00"
action:
  - alias: Create backup now
    service: backup.create
    data: {}
```

Start the automation at 3:30 AM so that the backup process will have time to finish before resulting tar is moved, at 4 AM, to the backup directory of the stack.