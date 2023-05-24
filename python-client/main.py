import io
import time

from PIL import Image
from fastapi import FastAPI, UploadFile
from inky import InkyWHAT
from inky.auto import auto

app = FastAPI()


@app.post('/upload-timetable/')
async def upload_image(file: UploadFile):
    contents = await file.read()
    try:
        screen = auto()
    except RuntimeError:
        screen = InkyWHAT('black')

    img = Image.open(io.BytesIO(contents))
    img = img.resize(screen.resolution, resample=Image.LANCZOS)

    if type(screen) != InkyWHAT:
        pal_img = Image.new("P", (1, 1))
        pal_img.putpalette((255, 255, 255, 0, 0, 0, 255, 255, 255) + (0, 0, 0) * 252)

        img = img.convert("RGB").quantize(palette=pal_img)
    else:
        thresh = 200
        img = img.convert('1').point(lambda x: 255 if x < thresh else 0, mode='1')

    screen.set_image(img)
    screen.show()

    return {"message": "Upload successful."}


@app.post('/clear-screen/')
async def clear_screen(cycles: int = 1):
    try:
        screen = auto()
    except RuntimeError:
        screen = InkyWHAT('black')

    colours = (screen.BLACK, screen.WHITE)

    # Create a new canvas to draw on
    img = Image.new("P", screen.resolution)

    # Loop through the specified number of cycles and completely
    # fill the display with each colour in turn.
    for _ in range(cycles):
        for color in colours:
            img.paste(color, (0, 0, img.size[0], img.size[1]))
            screen.set_image(img)
            screen.show()
            time.sleep(1)

    return {"message": "Cleaning complete."}

