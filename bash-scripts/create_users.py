# Using python script create_users.py

import subprocess

users = ["alice", "bob", "charlie"]
group = "devteam"
default_shell = "/bin/bash"
home_base = "/home"

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

def user_exists(username):
    try:
        subprocess.run(["id", username], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

# Create group if it doesn't exist
try:
    subprocess.run(["getent", "group", group], stdout=subprocess.DEVNULL, check=True)
    print(f"Group {group} already exists.")
except subprocess.CalledProcessError:
    print(f"Creating group: {group}")
    run(f"groupadd {group}")

for user in users:
    if user_exists(user):
        print(f"User {user} already exists.")
        continue

    print(f"Creating user: {user}")
    run(f"useradd -m -d {home_base}/{user} -s {default_shell} -g {group} {user}")
    run(f"echo '{user}:Password123!' | chpasswd")
    run(f"chmod 750 {home_base}/{user}")
    run(f"chown {user}:{group} {home_base}/{user}")

print("✅ All users created and configured.")