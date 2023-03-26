import requests

if __name__ == '__main__':
    with open("photo.jpg", "rb") as img:
        headers = {'accept': 'application/json'}
        response = requests.post("http://127.0.0.1:8000/uploadimage/", headers=headers, files={'file': img})
        print(response.text)
