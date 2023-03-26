import os.path
import io
import tempfile

import requests
from fastapi import FastAPI, UploadFile
from requests import status_codes

from raspberry_pis_scanner import RaspberryPisScanner

app = FastAPI()
scanner = RaspberryPisScanner()


@app.get('/')
async def root():
    return {'message': 'Hello World'}


@app.get('/scan_pis')
async def scan_pis():
    return scanner.scan()


@app.get('/pi/{ip_addr}')
async def pi(ip_addr: str):
    response = requests.get(f'http://{ip_addr}:8000/')
    if response.status_code != status_codes.codes['ok']:
        return {'response': f'pi not found at {ip_addr}'}
    return response.json()


@app.post('/pi/{pi_id}/upload-timetable/')
async def upload_timetable(pi_id: str, file: UploadFile):
    with tempfile.NamedTemporaryFile() as temp_file:
        temp_file.name = file.filename
        temp_file.write(await file.read())

        headers = {
            'accept': 'application/json',
            'filename': file.filename
        }
        response = requests.post(f"http://{pi_id}:8000/upload-timetable/", headers=headers, files={'file': temp_file})
        print(response.text)
    await file.close()

    return {"response": "upload successful"}
