#!/usr/bin/env python

from Xlib import X
from Xlib.ext.xtest import fake_input
from Xlib.display import Display
from time import sleep, localtime

import csv

import gtk
import gtk.glade

import threading


class MainWin():

    def __init__(self):
        self.clicks = []
        self.stop = False
        self.gladefile = "autoclicker.glade"
        self.wTree = gtk.glade.XML(self.gladefile, "MainWin")
        self.window = self.wTree.get_widget("MainWin")
        self.ac = Autoclicker(self.wTree)
        self.r = Recorder(self.wTree) 
        self.clicklist = self.wTree.get_widget("treeview")
        cr_x = gtk.CellRendererText()
        cr_x.set_property("editable", True)
        cr_x.connect("edited", self.row_edited, 0)
        cr_y = gtk.CellRendererText()
        cr_y.set_property("editable", True)
        cr_y.connect("edited", self.row_edited, 1)
        cr_button = gtk.CellRendererText()
        cr_button.set_property("editable", True)
        cr_button.connect("edited", self.row_edited, 2)
        cr_delay = gtk.CellRendererText()
        cr_delay.set_property("editable", True)
        cr_delay.connect("edited", self.row_edited, 3)
        col_x = gtk.TreeViewColumn("X", cr_x, text=0)
        col_y = gtk.TreeViewColumn("Y", cr_y, text=1)
        col_button = gtk.TreeViewColumn("Button", cr_button, text=2)
        col_delay = gtk.TreeViewColumn("Delay", cr_delay, text=3)
        for col in [col_x, col_y, col_button, col_delay]:
            col.set_resizable(True)
            self.clicklist.append_column(col)
        self.model = gtk.ListStore(str, str, str, str)
        self.clicklist.set_model(self.model)
        self.clicksel = self.clicklist.get_selection()
        self.clicksel.set_mode(gtk.SELECTION_MULTIPLE)
        signals = {"on_menuNew_activate": self.new,
                   "on_menuOpen_activate": self.open_dialog,
                   "on_menuSave_activate": self.save_dialog,
                   "on_menuExit_activate": self.quit,
                   "on_menuAdd_activate": self.add_row,
                   "on_menuRemove_activate": self.remove_row,
                   "on_menuInfo_activate": self.info_dialog,
                   "on_btnRecord_clicked": self.record,
                   "on_btnStopRec_clicked": self.stop_recording,
                   "on_btnAdd_clicked": self.add_row,
                   "on_btnRemove_clicked": self.remove_row,
                   "on_btnExit_clicked": self.quit,
                   "on_btnStop_clicked": self.stop_clicking,
                   "on_btnStart_clicked": self.start_clicking,
                   "on_MainWin_destroy": self.quit}
        self.wTree.signal_autoconnect(signals)
        self.window.show_all()
        self.cb = ClickBind(self.ac, self.r)
        self.cb.run()
        self.main_loop()

    def new(self, widget=None):
        self.model.clear()

    def open_dialog(self, widget=None):
        self.openTree = gtk.glade.XML(self.gladefile, "OpenWin")
        signals = {"on_btnOpen_clicked": self.open,
                   "on_fcOpen_file_activated": self.open,
                   "on_btnCancelOpen_clicked": self.close_win}
        self.openTree.signal_autoconnect(signals)
        self.openTree.get_widget("OpenWin").show_all()

    def open(self, widget):
        fn = self.openTree.get_widget("fcOpen").get_filename()
        self.close_win(widget)
        try:
            f = csv.reader(open(fn), delimiter=",")
        except IOError:
            self.error_dialog(msg="Error reading the file!")
        clicks = [row for row in f]
        if self.check_clicks(clicks) is False:
            self.error_dialog(msg="Malformed file!")
        else:
            self.clicks = clicks
            self.new()
            self.update_table()

    def check_clicks(self, list):
        for elem in list:
            try:
                x, y, button, delay = int(elem[0]), int(elem[1]), \
                                      int(elem[2]), int(elem[3])
            except ValueError:
                return False
            else:
                if button < 1 or button > 3 or delay < 1:
                    return False

    def save_dialog(self, wiget=None):
        self.saveTree = gtk.glade.XML(self.gladefile, "SaveWin")
        signals = {"on_btnSave_clicked": self.save,
                   "on_fcSave_file_activated": self.save,
                   "on_btnCancelSave_clicked": self.close_win}
        self.saveTree.signal_autoconnect(signals)
        self.saveTree.get_widget("SaveWin").show_all()

    def save(self, widget=None):
        fn = self.saveTree.get_widget("fcSave").get_filename()
        self.close_win(widget)
        try:
            f = csv.writer(open(fn, "w"), delimiter=",")
        except IOError:
            self.error_dialog(msg="Error saving the file!")
        f.writerows(self.get_table_values())

    def quit(self, widget=None):
        self.r.stop = True
        self.ac.stop = True
        self.cb.stop = True
        self.stop = True

    def add_row(self, widget=None):
        default_delay = self.wTree.get_widget("sbDelay").get_value()
        self.model.append([0, 0, 1, int(default_delay)])

    def remove_row(self, widget=None):
        model, pathlist = self.clicksel.get_selected_rows()
        if pathlist:
            for i, rowpath in enumerate(pathlist):
                iter = model.get_iter(path=(rowpath[0] - i,))
                model.remove(iter)

    def info_dialog(self, widget=None):
        infoTree = gtk.glade.XML(self.gladefile, "infoWin")
        signals = {"on_infoWin_close": self.close_win,
                   "on_infoWin_response": lambda d, r: d.destroy()}
        infoTree.signal_autoconnect(signals)
        infoTree.get_widget("infoWin").show_all()

    def record(self, widget=None):
        if self.ac.stop is not False:
            self.r.stop = False
            self.r.run()

    def stop_recording(self, widget=None):
        self.r.stop = True
        self.clicks = self.r.clicks[:-1]
        self.r.clicks = []
        self.update_table()

    def start_clicking(self, widget=None):
        if self.r.stop is not False:
            self.wTree.get_widget("btnStop").set_property("sensitive", True)
            self.wTree.get_widget("btnStart").set_property("sensitive", False)
            self.clicks = self.get_table_values()
            self.ac.clicks = self.clicks
            self.ac.loops = self.wTree.get_widget("sbLoops").get_value()
            self.ac.stop = False
            self.ac.run()

    def stop_clicking(self, widget=None):
        self.wTree.get_widget("btnStop").set_property("sensitive", False)
        self.wTree.get_widget("btnStart").set_property("sensitive", True)
        self.ac.stop = True

    def close_win(self, widget):
        widget.get_parent_window().destroy()

    def row_edited(self, cell, rowpath, new, col_id):
        try:
            n = int(new)
            if col_id == 2 and (n < 1 or n > 3) or col_id == 3 and n < 1:
                raise ValueError
        except ValueError:
            self.error_dialog(msg="Invalid Data!")
        else:
            iter = self.model.get_iter(rowpath)
            self.model.set_value(iter, col_id, new)

    def get_table_values(self):
        list = []
        iter = self.model.get_iter_first()
        while iter:
            x, y, button, delay = self.model.get(iter, 0, 1, 2, 3)
            list.append((int(x), int(y), int(button), int(delay)))
            iter = self.model.iter_next(iter)
        return list

    def update_table(self):
        for x, y, button, delay in self.clicks:
            self.model.append([str(x), str(y), str(button), str(delay)])

    def error_dialog(self, widget=None, data=None, msg="Error!"):
        message = gtk.MessageDialog(None, gtk.DIALOG_MODAL, gtk.MESSAGE_ERROR,
        gtk.BUTTONS_CLOSE, msg)
        message.show()
        resp = message.run()
        if resp == gtk.RESPONSE_CLOSE:
            message.destroy()

    def main_loop(self):
        while self.stop is False:
            while gtk.events_pending():
                gtk.main_iteration()


class Autoclicker(threading.Thread):

    def __init__(self, wTree=None):
        super(Autoclicker, self).__init__()
        self.wTree = None
        if wTree is not None:
            self.wTree = wTree
        self.stop = True
        self.loops = 0
        self.display = Display()
        self.root = self.display.screen().root

    def update_status(self, x, y, button, delay):
        msg = "Clicking button %d in %d, %d. Now waiting %d secs" % \
                (button, x, y, delay)
        self.wTree.get_widget("status").push(1, msg)

    def run(self):
        print "START AUTOCLICKING THREAD"
        if len(self.clicks) > 0:
            i = 1
            while not self.stop is True:
                if not self.loops == 0 and i > self.loops:
                    break
                i += 1
                for x, y, button, delay in self.clicks:
                    if self.stop is True:
                        break
                    print "Clicking in %d, %d" % (x, y)
                    if self.wTree is not None:
                        self.update_status(x, y, button, delay)
                    self.root.warp_pointer(x, y)
                    self.display.sync()
                    sleep(0.1)
                    fake_input(self.display, X.ButtonPress, button)
                    self.display.sync()
                    sleep(0.1)
                    fake_input(self.display, X.ButtonRelease, button)
                    self.display.sync()
                    start_time = localtime().tm_sec
                    while not (start_time - localtime().tm_sec) % delay == 0 \
                            or localtime().tm_sec == start_time:
                        while gtk.events_pending():
                            gtk.main_iteration()
                        click = self.root.query_pointer().mask
                        if self.stop is True or click > 500 and click < 600:
                            break
                        sleep(0.1)
        if self.wTree is not None:
            self.wTree.get_widget("btnStop").set_property("sensitive", False)
            self.wTree.get_widget("btnStart").set_property("sensitive", True)
        self.stop = True


class Recorder(threading.Thread):

    def __init__(self, wTree=None):
        super(Recorder, self).__init__()
        self.wTree = None
        if wTree is not None:
            self.wTree = wTree
        self.clicks = []
        self.default_delay = 5
        self.stop = True
        self.display = Display()
        self.root = self.display.screen().root

    def update_status(self, x, y, button):
        msg = "Recording button %d in %d, %d." % (button, x, y)
        self.wTree.get_widget("status").push(1, msg)

    def run(self):
        print "START RECORDING THREAD"
        if self.wTree is not None:
            self.wTree.get_widget("btnStopRec").set_property( \
                        "sensitive", True)
            self.wTree.get_widget("btnRecord").set_property( \
                        "sensitive", False)
            self.default_delay = self.wTree.get_widget( \
                        "sbDelay").get_value()
        while True:
            while gtk.events_pending():
                gtk.main_iteration()
            if self.stop is True:
                print "STOP RECORDING THREAD"
                break
            click = self.root.query_pointer().mask
            x = self.root.query_pointer()._data["root_x"]
            y = self.root.query_pointer()._data["root_y"]
            button = None
            if click > 200 and click < 300:
                button = 1
            elif click > 500 and click < 600:
                button = 2
            elif click > 1000 and click < 1100:
                button = 3
            if button is not None and self.wTree is not None:
                print "click in", x, y, button
                self.update_status(x, y, button)
                self.clicks.append((x, y, button, int(self.default_delay)))
                sleep(0.1)
        if self.wTree is not None:
            self.wTree.get_widget("btnStopRec").set_property( \
                    "sensitive", False)
            self.wTree.get_widget("btnRecord").set_property( \
                    "sensitive", True)


class ClickBind(threading.Thread):
    def __init__(self, ac, r):
        super(ClickBind, self).__init__()
        self.stop = False
        self.ac = ac
        self.r = r
        self.display = Display()
        self.root = self.display.screen().root

    def run(self):
        while self.stop is not True:
            click = self.root.query_pointer().mask
            print click
            if click > 500 and click < 600:
                print ":O"
                if self.ac.stop is False:
                    self.ac.stop = True
                elif self.ac.stop is False:
                    self.r.stop = True
                    self.ac.stop = False
                    self.ac.run()
            while gtk.events_pending():
                gtk.main_iteration()

if __name__ == "__main__":
    w = MainWin()
