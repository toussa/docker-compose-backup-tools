# docker-compose-backup-tools
Set of bash scripts to handle backups of docker directories and volumes. Works for docker-compose.

These scripts are old (2016) and not maintained anymore.
The reason behind is the use of docker swarm and no longer docker-compose.

## Small description of files

- *backup_batch.sh* is the main script (to launch with cron or manually with a backup-config filepath)
- *backup.d/* contains all backup-config files. Each file corresponds to a stack and contains some variables that will be used for backups.
- *clean_backup_dir.sh* is launch with cron and clean unwanted (anymore) backups. Only backups kept:
    - last 7 days
    - last 4 weeks (first day of week)
    - last 13 months (first day of month)
- *docker_clone_volume.sh*: convenience script to clone a named volume into another one (see [author's repo](https://github.com/gdiepen/))
- *named_volume_backup.sh* : script to backup a named volume into a tar file
- *named_volume_restore.sh* : script to restore a backup-ed tar file into a named volume.


*./backup.d/websiteBackup.conf*: sample of a conf file. It contains at most 5 variables, and at least Project_name and Config_dir.

I don't recommend using these scripts (security considerations) but it can give ideas.
