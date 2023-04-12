from typing import List, Tuple
import os
import io

import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from firebase_admin import db


class FirebaseService:
    """
    Handles communication with the firebase storage and database.
    """
    BUCKET = 'einktimetables.appspot.com'
    DB = 'https://einktimetables-default-rtdb.europe-west1.firebasedatabase.app/'
    DB_ROOT = '/rasp_pis'
    PRIVATE_KEY = 'private_key.json'

    def __init__(self):
        self._cred = credentials.Certificate(self.PRIVATE_KEY)
        self._init_app()
        self._bucket = storage.bucket()

    def _init_app(self):
        firebase_admin.initialize_app(self._cred, {
            'storageBucket': self.BUCKET,
            'databaseURL': self.DB
        })

    def _add_url_to_db(self, rasp_id: str, blob_name: str, url: str):
        """
        Updates the list of url images from firebase db for the provided Raspberry Pi ID.
        :param rasp_id: Raspberry Pi ID
        :param url: image url
        :return:
        """
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}/images')
        ref.push({'blob_name': blob_name,  'url': url})

    def _upload_img(self, img_name: str, contents: bytes) -> Tuple[str, str]:
        """
        Uploads the image provided as bytes to firebase storage.
        :param img_name: image name
        :param contents: image as bytes
        :return: the public url of the image
        """
        blob = self._bucket.blob(img_name)
        _, ext = os.path.splitext(img_name)

        blob.upload_from_string(io.BytesIO(contents).read(), content_type=f'image/{ext[1:]}')
        blob.make_public()

        return blob.name, blob.public_url

    def update_clear_status(self, rasp_id: str, is_clear: bool):
        """
        Updates the status of the screen for the provided Raspberry Pi ID.
        :param rasp_id: image name
        :param is_clear: screen status
        :return:
        """
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}/is_clear')
        ref.set(is_clear)

    def update_timetable_history(self, rasp_id: str,  img_name: str, contents: bytes):
        """
        Uploads the provided images to firebase storage and updates the list of images associated with the provided
        Raspberry Pi ID.
        :param rasp_id: Raspberry Pi ID
        :param img_name: image name
        :param contents: image as bytes
        :return:
        """
        blob_name, img_url = self._upload_img(img_name, contents)
        self._add_url_to_db(rasp_id, blob_name, img_url)
        self.update_clear_status(rasp_id, False)

    def get_rasp_status(self, rasp_id: str) -> object:
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}')
        rasp_details = ref.get()

        return {'id': rasp_id, 'details': rasp_details}
