import requests
from fastapi import FastAPI, UploadFile, HTTPException, status

from raspberry_pis_manager import RaspberryPisManager, InvalidPiIdError, PiNotFoundError, UnregisteredPiIdError
from raspberry_pis_scanner import RaspberryPisScanner

app = FastAPI()
scanner = RaspberryPisScanner()
manager = RaspberryPisManager()


@app.get('/')
async def root():
    return {'message': 'Hello World'}


@app.get('/scan_pis')
async def scan_pis():
    return scanner.scan()


@app.post('/register/{pi_id}')
async def register_pi(pi_id: str):
    try:
        manager.register_pi(pi_id)
    except InvalidPiIdError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except PiNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@app.post('/pi/{pi_id}/upload-timetable/')
async def upload_timetable(pi_id: str, file: UploadFile):
    try:
        pi_ip_addr = manager.resolve_pi_id(pi_id)
    except UnregisteredPiIdError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    contents = await file.read()

    headers = {
        'accept': 'application/json',
        'filename': file.filename
    }
    response = requests.post(f"http://{pi_ip_addr}:8000/upload-timetable/", headers=headers,
                             files={'file': contents})
    response.raise_for_status()

    await file.close()

    return "Upload successful."


@app.post('/pi/{pi_id}/clear-screen/')
async def clear_screen(pi_id: str):
    try:
        pi_ip_addr = manager.resolve_pi_id(pi_id)
    except UnregisteredPiIdError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    response = requests.post(f"http://{pi_ip_addr}:8000/clear-screen/")
    response.raise_for_status()

    return response.text
