import base64
import binascii
from typing import Optional

from raspberry_pis_scanner import RaspberryPisScanner


class PiNotFoundError(RuntimeError):
    def __init__(self, rasp_id: str):
        super().__init__(f"No Raspberry Pi with the provided ID ({rasp_id}) could be found on the network.")


class InvalidPiIdError(RuntimeError):

    def __init__(self, rasp_id: str):
        super().__init__(f'Provided Raspberry Pi ID ({rasp_id}) is not a valid id.')


class UnregisteredPiIdError(RuntimeError):

    def __init__(self, rasp_id: str):
        super().__init__(f'No Raspberry Pi was registered wit the provided ID ({rasp_id}).')


class RaspberryPisManager:
    registered_pis = {}

    def __init__(self):
        self.scanner = RaspberryPisScanner()

    @staticmethod
    def _get_pi_id(mac: str) -> str:
        mac_bytes = bytes.fromhex(mac.replace(':', '').replace('-', ''))
        return base64.urlsafe_b64encode(mac_bytes).decode('utf-8')

    @staticmethod
    def _get_pi_mac(pi_id: str) -> str:
        try:
            return base64.urlsafe_b64decode(pi_id).hex()
        except binascii.Error:
            raise InvalidPiIdError(pi_id)

    def _update_registered_pis(self):
        self.registered_pis.update({self._get_pi_id(mac): ip for mac, ip in self.scanner.scan().items()})

    def register_pi(self, pi_id):
        if pi_id in self.registered_pis:
            return self.registered_pis[pi_id]

        pi_mac = self._get_pi_mac(pi_id)
        ip_addr = self.scanner.get_ip_from_arp_table(pi_mac)
        if ip_addr is None:
            self.scanner.scan()
            ip_addr = self.scanner.get_ip_from_arp_table(pi_mac)
            if ip_addr is None:
                raise PiNotFoundError(pi_id)
            self.registered_pis[pi_id] = ip_addr

    def resolve_pi_id(self, pi_id: str) -> str:
        ip_addr = self.registered_pis.get(pi_id, None)

        if ip_addr is None:
            raise UnregisteredPiIdError(pi_id)

        return ip_addr


if __name__ == '__main__':
    # 5F8Boi3k
    manager = RaspberryPisManager()
