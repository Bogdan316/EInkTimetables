# Raspberry Pi Client
1. clone the branch
2. cd into the cloned directory
3. run `docker build -t client .`
4. run `docker run --privileged -d --name client-container -p 80:80 client` <br /> (the `--privileged` option is needed to have access to the GPIO inside the container)

**Note:** make sure you enable I2C and SPI using `sudo raspi-config`
