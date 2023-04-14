import multiprocessing
import re
import socket
import subprocess
from typing import Optional, Dict, List
from datetime import datetime


class RaspberryPisScanner:
    """
    Updates the ARP table using a ping sweep.
    """
    ip_address_regex = r'(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}' \
                       r'(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])'
    mac_address_regex = r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})'
    raspberry_pi_mac_prefixes: List[str] = ['28CDC1', 'B827EB', 'DC2632', 'E45F01']

    arp_table: Dict[str, str] = {}

    def __init__(self):
        self.network_address = self._get_network_address()
        self.live_hosts = []
        self.last_scan: Optional[datetime] = None
        self.last_scan_result = None

    @staticmethod
    def _get_network_address() -> str:
        """
        Returns the network address a /24 mask is assumed.
        :return: the host network address
        """
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
        """
        Pings the provided ip address.
        :param address: ip address.
        :return: the ip address if the host responded to the ping
        """
        process_result = subprocess.run(['/usr/bin/ping', '-c1', address],
                                        stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        if process_result.returncode == 0:
            return address

    @staticmethod
    def _format_mac(mac: str) -> str:
        """
        Gets only the hex values from the provided MAC address.
        :param mac: MAC address
        :return: string with hex values
        """
        return mac.lower().replace(':', '').replace('-', '')

    def _ping_sweep(self):
        """
        Does multiple pings in parallel to scan the network.
        :return: a list with the hosts that responded to pings
        """
        with multiprocessing.Pool(50) as pool:
            results = pool.map(self._ping_host, (self.network_address + f'.{i}' for i in range(1, 256)))

        self.live_hosts = [ip for ip in results if ip is not None]

    def _get_arp_table(self):
        """
        Extracts the MAC and ip address for each host from the ARP table and updates the arp_table dict.
        :return:
        """
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
                    self.arp_table[self._format_mac(mac_addr.group(0))] = arp_host

    def get_ip_from_arp_table(self, mac: str) -> Optional[str]:
        """
        Checks if the provided MAC address has an ip address associated in the ARP table if not updates the ARP table
        one more time before checking again.
        :param mac: MAC address
        :return: ip address corresponding to the provided MAC
        """
        if mac not in self.arp_table:
            self._get_arp_table()

        return self.arp_table.get(mac, None)

    def scan(self, force: bool = False):
        """
        Does a ping sweep of the network (/24 mask is assumed) and updates the current view of the ARP table.
        :return:
        """
        # make a scan only every 30 minutes
        if not force and (self.last_scan and (self.last_scan - datetime.now()).total_seconds() <= 1800):
            return self.last_scan_result

        self._ping_sweep()
        self._get_arp_table()

        self.last_scan = datetime.now()
        self.last_scan_result = {mac: ip for mac, ip in self.arp_table.items()
                                 if any([mac.startswith(pi_mac.lower()) for pi_mac in self.raspberry_pi_mac_prefixes])}

        return self.last_scan_result
