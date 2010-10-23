function fastweb_pirelli(ssid) {
    var magic = "\x22\x33\x11\x34\x02\x81\xFA\x22\x11\x41" +
                "\x68\x11\x12\x01\x05\x22\x71\x42\x10\x66";
    var h = "";
    for (i=0;i < ssid.length - ssid.length % 2; i+=2) {
        h += String.fromCharCode(parseInt(ssid.substring(i, i+2), 16));
    }
    h += magic;
    h = calcMD5(h);
    var b = new Array();
    for (i=0, j=0;i < h.length - h.length % 2;i+=2, j++) {
        b[j] = fill(deciToBin(parseInt(h.substring(i, i+2), 16)), 8).toString();
    }
    b = b.slice(0, 5);
    b = b.join("");
    var r = new Array();
    for (i=0, j=0;i < b.length - b.length % 5; i+=5, j++) {
        r[j] = b.substring(i, i+5);
    }
    w = ""
    for (i=0;i<5;i++) {
        var a = parseInt(r[i], 2);
        if (a >= 10)
            a += 87;
        w += fill(a.toString(16), 2)
    }
    return w;
}

function calculate() {
    var ssid = document.getElementById("ssid").value;
    var t = document.getElementById("type").selectedIndex;
    var res = "";
    if (t == 0) {
        res = fastweb_pirelli(ssid);
    }
    document.getElementById("ssid").value = res;
}
