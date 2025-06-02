# python script to check if a web service is up 

import requests

def check_service(url):
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            print(f"{url} is UP")
        else:
            print(f"{url} returned status code {response.status_code}")
    except requests.exceptions.RequestException:
        print(f"{url} is DOWN")

check_service("https://yourapp.com")