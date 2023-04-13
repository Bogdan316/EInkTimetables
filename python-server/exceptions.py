class PiNotFoundError(RuntimeError):
    def __init__(self, rasp_id: str):
        super().__init__(f"The Raspberry Pi with the provided ID ({rasp_id}) could be found on the network.")


class InvalidPiIdError(RuntimeError):

    def __init__(self, rasp_id: str):
        super().__init__(f'Provided Raspberry Pi ID ({rasp_id}) is not a valid ID.')


class UnregisteredPiIdError(RuntimeError):

    def __init__(self, rasp_id: str):
        super().__init__(f'No Raspberry Pi was registered with the provided ID ({rasp_id}).')


class UnreachablePiError(RuntimeError):

    def __init__(self, rasp_id: str):
        super().__init__(f'The Raspberry Pi with the provided ID ({rasp_id}) could not be reached.')


class ImageNotFoundError(RuntimeError):

    def __init__(self, img_name: str):
        super().__init__(f'The image with the provided name ({img_name}) could not be found.')
