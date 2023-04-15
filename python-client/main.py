import io
import time

from PIL import Image
from fastapi import FastAPI, UploadFile
from inky import InkyWHAT

app = FastAPI()


@app.post('/upload-timetable/')
async def upload_image(file: UploadFile):
    contents = await file.read()

    display = InkyWHAT('black')

    img = Image.open(io.BytesIO(contents))
    img = img.resize(display.resolution)
    thresh = 200
    img = img.convert('1').point(lambda x: 255 if x < thresh else 0, mode='1')

    display.set_image(img)
    display.show()

    return {"message": "Upload successful."}


@app.post('/clear-screen/')
async def clear_screen(cycles: int = 1):
    screen = InkyWHAT('black')

    colours = (screen.BLACK, screen.WHITE)

    # Create a new canvas to draw on
    img = Image.new("P", (screen.WIDTH, screen.HEIGHT))

    # Loop through the specified number of cycles and completely
    # fill the display with each colour in turn.
    for i in range(cycles):
        for color in colours:
            img.paste(color, (0, 0, img.size[0], img.size[1]))
            screen.set_image(img)
            screen.show()
            time.sleep(1)

    return {"message": "Cleaning complete."}

