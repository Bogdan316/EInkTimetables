import io
import time

from PIL import Image
from fastapi import FastAPI, UploadFile
from inky.auto import auto

app = FastAPI()


@app.post('/upload-timetable/')
async def upload_image(file: UploadFile):
    contents = await file.read()

    screen = auto()

    img = Image.open(io.BytesIO(contents))

    w, h = img.size

    # Calculate the new height and width of the image

    h_new = 300
    w_new = int((float(w) / h) * h_new)
    w_cropped = 400

    # Resize the image with high-quality resampling

    img = img.resize((w_new, h_new), resample=Image.LANCZOS)

    # Calculate coordinates to crop image to 400 pixels wide

    x0 = (w_new - w_cropped) // 2
    x1 = x0 + w_cropped
    y0 = 0
    y1 = h_new

    # Crop image

    img = img.crop((x0, y0, x1, y1))

    # Convert the image to use a white / black / red colour palette

    pal_img = Image.new("P", (1, 1))
    pal_img.putpalette((255, 255, 255, 0, 0, 0, 255, 0, 0) + (0, 0, 0) * 252)

    img = img.convert("RGB").quantize(palette=pal_img)

    # Display the final image on Inky wHAT

    screen.set_image(img)
    screen.show()

    return {"message": "Upload successful."}


@app.post('/clear-screen/')
async def clear_screen(cycles: int = 1):
    screen = auto()

    colours = (screen.BLACK, screen.WHITE)

    # Create a new canvas to draw on
    img = Image.new("P", screen.resolution)

    # Loop through the specified number of cycles and completely
    # fill the display with each colour in turn.
    for i in range(cycles):
        for color in colours:
            img.paste(color, (0, 0, img.size[0], img.size[1]))
            screen.set_image(img)
            screen.show()
            time.sleep(1)

    return {"message": "Cleaning complete."}

