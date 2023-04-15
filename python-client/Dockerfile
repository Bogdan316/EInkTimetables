FROM python:3.9

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

RUN pip3 install inky[rpi,example-depends]

COPY ./main.py /app/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]

