#!/bin/bash

# Script to monitor disk usage and alert when usage exceeds 80%.

# threshold=80
# df -H | grep '^/dev' | while read line; do
#   usage=$(echo $line | awk '{ print $5 }' | sed 's/%//g')
#   partition=$(echo $line | awk '{ print $1 }')
#   if [ "$usage" -gt "$threshold" ]; then
#     echo "Alert: $partition is $usage% full"
#     # Send email/slack notification logic here
#   fi
# done

threshold=80
df -H | grep '^/dev' | while read line; do
  usage=$(echo $line | awk '{ print $5 }' | sed 's/%//g')
  partition=$(echo $line | awk '{ print $1 }')
  if [ "$usage" -gt "$threshold" ]; then
    echo "Alert: $pertition is $usage% full"
    # Send email/slack notification logic here
  fi
done

# Automating clean up of log files older than 7 days
#!/bin/bash

find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;

# Script to back up a directory and upload it to aws s3 

#!/bin/bash
backup_dir="/home/user/data"
timestamp=$(date +%F)
tar -czf /tmp/backup_$timestamp.tar.gz $backup_dir
aws s3 cp /tmp/backup_$timestamp.tar.gz s3://my-backup-bucket/

