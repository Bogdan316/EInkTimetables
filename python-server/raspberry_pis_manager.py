import base64
import binascii

from exceptions import PiNotFoundError, InvalidPiIdError, UnregisteredPiIdError
from raspberry_pis_scanner import RaspberryPisScanner


class RaspberryPisManager:
    """
    Manages the registration of Raspberry Pis.
    Each Raspberry Pi has an ID that is generated from its MAC address,
    """
    registered_pis = {}

    def __init__(self):
        self.scanner = RaspberryPisScanner()

    @staticmethod
    def get_pi_id(mac: str) -> str:
        """
        Converts a mac address to a base64 id.
        :param mac: MAC address
        :return:
        """
        mac_bytes = bytes.fromhex(mac.replace(':', '').replace('-', ''))
        return base64.urlsafe_b64encode(mac_bytes).decode('utf-8')

    @staticmethod
    def _get_pi_mac(pi_id: str) -> str:
        """
        Converts an id back to a MAC address.
        :param pi_id: Raspberry Pi ID
        :return:
        """
        try:
            return base64.urlsafe_b64decode(pi_id).hex()
        except binascii.Error:
            raise InvalidPiIdError(pi_id)

    def register_pi(self, pi_id: str, force_scan: bool = False):
        """
        Resolves the ip address for the provided ID using the current ARP table and updates the list of
        registered Raspberry Pis if the Raspberry Pi with the provided ID is connected to the network.
        :param pi_id: Raspberry Pi ID
        :return:
        """
        if pi_id in self.registered_pis:
            return

        pi_mac = self._get_pi_mac(pi_id)
        ip_addr = self.scanner.get_ip_from_arp_table(pi_mac)
        if ip_addr is None:
            # if the MAC address is not found in the ARP table do a scan to update the ARP table
            self.scanner.scan(force_scan)
            ip_addr = self.scanner.get_ip_from_arp_table(pi_mac)
            if ip_addr is None:
                raise PiNotFoundError(pi_id)

        self.registered_pis[pi_id] = ip_addr

    def resolve_pi_id(self, pi_id: str) -> str:
        """
        Resolves the provided Raspberry Pi ID to an ip address.
        :param pi_id: Raspberry Pi ID
        :return: the ip address associated with the Raspberry Pi
        """
        ip_addr = self.registered_pis.get(pi_id, None)

        if ip_addr is None:
            raise UnregisteredPiIdError(pi_id)

        return ip_addr


if __name__ == '__main__':
    # 5F8Boi3k
    manager = RaspberryPisManager()
