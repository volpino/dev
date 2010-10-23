#!/usr/bin/env python

from Xlib import display
from time import sleep

try:
    while (1):
        d = display.Display()
        s = d.screen()
        root = s.root
        x = root.query_pointer()._data["root_x"]
        y = root.query_pointer()._data["root_y"]
        root.warp_pointer(x,y)
        d.sync()
        sleep(120)
except KeyboardInterrupt:
    print "\nNo more movies? :( See yaa"
