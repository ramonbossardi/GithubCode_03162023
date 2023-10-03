import requests

def restart_heroku_dynos():
    headers = {
        "Authorization": f"Bearer 78e11a96-8bc6-4fcc-8f07-b63b008f48f5",
        "Accept": "application/vnd.heroku+json; version=3"
    }

    response = requests.post(
        f"https://api.heroku.com/apps/fierce-journey-20199/dynos/restart",
        headers=headers
    )

    if response.status_code == 200:
        print("Heroku dynos restarted successfully.")
    else:
        print("Failed to restart Heroku dynos.")
        print(response.text)

