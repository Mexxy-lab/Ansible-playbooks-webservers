# 1) Write a script to automate a task, such as:- Deploying a simple web application to a remote server.
# In python use below code: deploy.py

import paramiko
from scp import SCPClient
import os

remote_user = 'ubuntu'
remote_host = 'your.server.com'
remote_dir = '/var/www/html'
local_dir = './site'
web_service = 'apache2'  # or nginx

def create_ssh_client():
    key = paramiko.RSAKey.from_private_key_file(os.path.expanduser('~/.ssh/id_rsa'))
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=remote_host, username=remote_user, pkey=key)
    return client

def deploy():
    try:
        print("🔐 Connecting...")
        ssh = create_ssh_client()
        scp = SCPClient(ssh.get_transport())

        print("📤 Uploading files...")
        for root, _, files in os.walk(local_dir):
            for file in files:
                local_path = os.path.join(root, file)
                relative_path = os.path.relpath(local_path, local_dir)
                remote_path = os.path.join(remote_dir, relative_path)
                scp.put(local_path, remote_path)

        print("🔁 Restarting web server...")
        stdin, stdout, stderr = ssh.exec_command(f"sudo systemctl restart {web_service}")
        print(stdout.read().decode())
        print(stderr.read().decode())

        print("✅ Deployment complete!")
        ssh.close()
    except Exception as e:
        print(f"❌ Deployment failed: {e}")

deploy()