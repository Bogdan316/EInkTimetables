import multiprocessing
import socket
import subprocess
import re
import base64

from typing import Optional, Dict, List


class RaspberryPisScanner:
    ip_address_regex = r'(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}' \
                       r'(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])'
    mac_address_regex = r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})'
    raspberry_pi_mac_prefixes: List[str] = ['28:CD:C1', 'B8:27:EB', 'DC:26:32', 'E4:5F:01']

    def __init__(self):
        self.network_address = self._get_network_address()
        self.live_hosts = []
        self.arp_table: Dict[str, str] = {}

    @staticmethod
    def _get_network_address() -> str:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(0)
        try:
            # doesn't even have to be reachable
            s.connect(('10.254.254.254', 1))
            ip = s.getsockname()[0]
        finally:
            s.close()

        # remove everything after the last dot
        network_address, *_ = ip.rpartition('.')

        return network_address

    @staticmethod
    def _ping_host(address: str) -> Optional[str]:
        process_result = subprocess.run(['/usr/bin/ping', '-c1', address],
                                        stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        if process_result.returncode == 0:
            return address

    def _ping_sweep(self):
        with multiprocessing.Pool(50) as pool:
            results = pool.map(self._ping_host, (self.network_address + f'.{i}' for i in range(1, 256)))

        self.live_hosts = [ip for ip in results if ip is not None]

    def _get_arp_table(self):
        process_result = subprocess.run(['/usr/sbin/arp', '-na'], capture_output=True)
        if process_result.returncode != 0:
            raise RuntimeError('Unable to access the ARP table.')

        arp_table = process_result.stdout.decode('utf-8')
        for table_line in arp_table.split('\n'):
            ip_addr = re.search(self.ip_address_regex, table_line)
            mac_addr = re.search(self.mac_address_regex, table_line)

            if ip_addr and mac_addr:
                arp_host = ip_addr.group(0)
                if arp_host in self.live_hosts:
                    self.arp_table[arp_host] = mac_addr.group(0)

    @staticmethod
    def _get_pi_id(mac: str) -> str:
        mac_bytes = bytes.fromhex(mac.replace(':', ''))
        return base64.urlsafe_b64encode(mac_bytes).decode('utf-8')

    def scan(self):
        self._ping_sweep()
        self._get_arp_table()

        return {ip: mac for ip, mac in self.arp_table.items()
                if any([mac.lower().startswith(pi_mac.lower()) for pi_mac in self.raspberry_pi_mac_prefixes])}


if __name__ == '__main__':
    scanner = RaspberryPisScanner()
    print(scanner.scan())
