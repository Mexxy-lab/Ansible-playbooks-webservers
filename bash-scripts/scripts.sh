# DevOps Scripting Challenges with Solutions (Advanced)

---

## 1. Regex Parsing & File Analysis

### Problem:
You have a log file `/var/log/app.log` with mixed entries. Extract all valid email addresses from it using:
- Bash
- Python

### Bash Solution:
```bash
grep -E -o "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" /var/log/app.log
```

### Python Solution:
```python
import re

with open('/var/log/app.log', 'r') as file:
    content = file.read()
    emails = re.findall(r"[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}", content)
    print("\n".join(emails))
```

---

## 2. Service Orchestration & Health Checks

### Problem:
Write a Bash script to:
- Check if `nginx` and `mysql` are running
- If not, restart them
- Log any restart actions to `/var/log/service-monitor.log`

### Bash Solution:
```bash
#!/bin/bash
SERVICES=(nginx mysql)
for service in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet "$service"; then
    echo "[$(date)] Restarting $service..." >> /var/log/service-monitor.log
    systemctl restart "$service"
  fi
done
```

## 3. CI/CD Pipeline Automation (YAML & Script)

### Problem:
Create a script that:
- Installs Node.js dependencies
- Runs tests
- Deploys to S3 bucket using AWS CLI

### Bash Solution:
```bash
#!/bin/bash
npm install
npm test
aws s3 sync ./dist s3://my-ci-cd-bucket --delete
```

### GitHub Actions YAML:
```
name: CI/CD Node.js App
on:
  push:
    branches: [ main ]
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
      - run: aws s3 sync ./dist s3://my-ci-cd-bucket --delete
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_KEY }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET }}
```

## 4. Real-World Log Parsing (Nginx)

### Problem:
Count number of requests from each IP in `/var/log/nginx/access.log`

### Bash Solution:
```bash
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr
```

### Python Solution:
```python
from collections import Counter

with open('/var/log/nginx/access.log') as f:
    ips = [line.split()[0] for line in f if line.strip()]
    for ip, count in Counter(ips).most_common():
        print(f"{ip}: {count}")
```

## 5. AWS SDK Scripting (Boto3)

### Problem:
List all EC2 instances with their name and state.

### Python Solution:
```python
import boto3

ec2 = boto3.client('ec2')
response = ec2.describe_instances()

for r in response['Reservations']:
    for i in r['Instances']:
        name = next((t['Value'] for t in i.get('Tags', []) if t['Key'] == 'Name'), 'Unnamed')
        print(f"{name}: {i['InstanceId']} - {i['State']['Name']}")
```