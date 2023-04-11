import requests
from fastapi import FastAPI, UploadFile, status, Request
from fastapi.responses import JSONResponse

from exceptions import PiNotFoundError, InvalidPiIdError, UnregisteredPiIdError, UnreachablePiError
from firebase_service import FirebaseService
from raspberry_pis_manager import RaspberryPisManager
from raspberry_pis_scanner import RaspberryPisScanner

app = FastAPI()
scanner = RaspberryPisScanner()
manager = RaspberryPisManager()
service = FirebaseService()


@app.get('/')
async def root():
    return {'message': 'Server is up.'}


@app.get('/scan_pis')
async def scan_pis():
    scan_results = scanner.scan()
    response = [manager.get_pi_id(pi_mac) for pi_mac in scan_results]

    return {'active pis': response}


@app.post('/register/mac/{pi_mac}')
async def register_pi_mac(pi_mac: str):
    pi_id = manager.register_pi(manager.get_pi_id(pi_mac))

    return {"rasp pi id": pi_id}


@app.post('/register/id/{pi_id}')
async def register_pi_id(pi_id: str):
    manager.register_pi(pi_id)

    return {"message": "Register successful."}


@app.post('/pi/{pi_id}/upload-timetable/')
async def upload_timetable(pi_id: str, file: UploadFile):
    """
    Sends the provided file to the screen with the corresponding Raspberry Pi ID, updates the firebase backend.
    :param pi_id: Raspberry Pi ID
    :param file: uploaded file
    :return:
    """
    contents = await file.read()

    pi_ip_addr = manager.resolve_pi_id(pi_id)
    headers = {'accept': 'application/json', 'filename': file.filename}
    response = requests.post(f"http://{pi_ip_addr}:8000/upload-timetable/", headers=headers, files={'file': contents})

    await file.close()

    if not response.ok:
        raise UnreachablePiError(pi_id)

    service.update_timetable_history(pi_id, file.filename, contents)
    return response.json()


@app.post('/pi/{pi_id}/clear-screen/')
async def clear_screen(pi_id: str, cycles: int = 1):
    """
    Clears the screen of the corresponding Raspberry Pi ID, updates the firebase backend.
    :param pi_id: Raspberry Pi ID
    :param cycles: number of black to white cycles to run on the screen
    :return:
    """
    pi_ip_addr = manager.resolve_pi_id(pi_id)

    response = requests.post(f"http://{pi_ip_addr}:8000/clear-screen/?cycles={cycles}")
    if not response.ok:
        raise UnreachablePiError(pi_id)

    service.update_clear_status(pi_id, True)
    return response.json()


@app.exception_handler(InvalidPiIdError)
async def invalid_pi_id_error_handler(_: Request, exc: InvalidPiIdError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={'message': str(exc)}
    )


@app.exception_handler(UnregisteredPiIdError)
async def unregistered_pi_id_error_handler(_: Request, exc: UnregisteredPiIdError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={'message': str(exc)}
    )


@app.exception_handler(PiNotFoundError)
async def pi_not_found_error_handler(_: Request, exc: PiNotFoundError):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={'message': str(exc)}
    )


@app.exception_handler(UnreachablePiError)
async def unreachable_pi_error_handler(_: Request, exc: PiNotFoundError):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={'message': str(exc)}
    )
