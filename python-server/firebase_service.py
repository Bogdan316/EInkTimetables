import json
from typing import List, Tuple, Dict
import os
import io
from datetime import datetime
from operator import itemgetter
import uuid

import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from firebase_admin import db

from exceptions import ImageNotFoundError


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

    def _add_url_to_db(self, rasp_id: str, blob_name: str, img_name: str, url: str):
        """
        Updates the list of url images from firebase db for the provided Raspberry Pi ID.
        :param rasp_id: Raspberry Pi ID
        :param url: image url
        :return:
        """
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}/images')
        ref.push({'blob_name': blob_name, 'img_name': img_name,  'url': url, 'upload_date': str(datetime.today())})

    def _upload_img(self, img_name: str, contents: bytes) -> Tuple[str, str]:
        """
        Uploads the image provided as bytes to firebase storage.
        :param img_name: image name
        :param contents: image as bytes
        :return: the public url of the image
        """
        blob = self._bucket.blob(str(uuid.uuid1()))
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
        if is_clear:
            self.update_displaying(rasp_id, '')

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
        self._add_url_to_db(rasp_id, blob_name, img_name, img_url)
        self.update_clear_status(rasp_id, False)
        self.update_displaying(rasp_id, blob_name)

    def get_rasp_status(self, rasp_id: str) -> object:
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}')
        rasp_details = ref.get()

        return {'id': rasp_id, 'details': rasp_details}

    def get_image_by_name(self, blob_name: str) -> bytes:
        blob = self._bucket.get_blob(blob_name)
        if blob is None:
            raise ImageNotFoundError(blob_name)

        return blob.download_as_bytes()

    def update_displaying(self, rasp_id: str, img_name: str):
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}/displaying')
        ref.set(img_name)

    @staticmethod
    def get_registered_rasp_pis() -> List[Dict]:
        rasp_pis = db.reference('rasp_pis').get()
        if rasp_pis is None:
            return []

        return [{'id': k, 'details': v} for k, v in rasp_pis.items()]

    def register_rasp_pi(self, rasp_id: str, rasp_name: str):
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}')
        ref.update({'name': rasp_name})

    def unregister_rasp_pi(self, rasp_id: str):
        ref = db.reference(f'{self.DB_ROOT}/{rasp_id}')
        ref.delete()

    def rename_rasp_pi(self, rasp_id: str, name: str):
        self.register_rasp_pi(rasp_id, name)

