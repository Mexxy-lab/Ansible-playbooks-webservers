# Problem: Write a script to automate a task, such as:
# Parsing log files to identify errors or anomalies.

import re
from datetime import datetime

# Define the log file and output report
log_file = 'application.log'
report_file = 'error_report.log'

# Define regex patterns for anomalies
patterns = [
    r'\bERROR\b',
    r'\bCRITICAL\b',
    r'failed login',
    r'latency: (\d+)ms'  # Detect high latency
]

# Thresholds (example: latency over 1000ms is an anomaly)
LATENCY_THRESHOLD_MS = 1000

def detect_anomaly(line):
    for pattern in patterns:
        match = re.search(pattern, line, re.IGNORECASE)
        if match:
            if 'latency' in pattern:
                latency = int(match.group(1))
                return latency > LATENCY_THRESHOLD_MS
            return True
    return False

# Process log file
with open(log_file, 'r') as infile, open(report_file, 'w') as outfile:
    for line in infile:
        if detect_anomaly(line):
            timestamp = datetime.now().isoformat()
            outfile.write(f"[{timestamp}] {line}")

print(f"✅ Anomaly report written to '{report_file}'")
