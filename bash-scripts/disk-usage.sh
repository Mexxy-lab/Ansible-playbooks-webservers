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



#!/bin/bash
# Loop through odd numbers 1 to 99
for ((i=1; i<=99; i+=2))
do
  echo "$i"
done


#!/bin/bash
# Read a single line of input (name)
read name

# Output the exact format: Welcome (name)
echo "Welcome $name"

#Use a for loop to display the natural numbers from 1 to 50.
#!/bin/bash

for ((i=1; i<=50; i++))
do
  echo "$i"
done

# Used to reverse the other of values 

sed -E 's/([0-9]{4}) ([0-9]{4}) ([0-9]{4}) ([0-9]{4})/\4 \3 \2 \1/'     # Used to reverse the other of values

sed -E 's/([0-9]{4}) ([0-9]{4}) ([0-9]{4}) ([0-9]{4})/\4 \3 \2 \1/' cards.txt


grep -i -w 'the'   # Used when the search is case insensitive. Would grep all entries with the

grep -i -w -v 'that'    # Used to remove entries with 'that'. Uses the invert flag and search is case insensitive 

grep -i -E '\b(the|that|then|those)\b' # \b -word boundaries, -i - case insensitive search -E enables extended regrex needed for using or |. 


Python 

if __name__ == '__main__':
    a = int(input())
    b = int(input())
    
    print (a // b)          # Integer division - gives integer 
    print (a / b)           # Float division - output a float 

# Use of for loop in python 

if __name__ == '__main__':
    n = int(input())
    for i in range(n):
        print(i ** 2)
