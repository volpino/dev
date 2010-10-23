"""
Pagine gialle parser

Cerca un termine su paginegialle.it e esporta in csv
"""

import urllib
import re
from BeautifulSoup import BeautifulSoup
import csv

def clean(s):
    r = {'&amp;': '&',
         '\n': '',
         'tel:': '',
         'fax:': '',
         'Categoria:': '',
         '&nbsp;': ' '}
    for key, value in r.items():
        s = s.replace(key, value)
    return s

def find_text(r, n=0):
    try:
        res = "".join(r[n].findAll(text=True))
    except IndexError:
        res = ""
    return res

def pagine_gialle_parser(url, file_csv, debug=False): 
    csvwriter = csv.writer(open(file_csv, 'w'))
    f = urllib.urlopen(url)
    soup = BeautifulSoup("".join([i for i in f]))
    try:
        pag_total = soup.findAll('p', {'class': 'pagination-total'})[0]
    except IndexError:
        if debug:
            print "Errore! Nessun risultato trovato :("
        return False
    pag = "".join(pag_total.findAll('span', {'class': 'orange'})[1].findAll(text=True))
    if debug:
        print "totale pagine:", pag

    for i in range(1, int(pag) + 1):
        if debug:
            print "elaborando pag", i
        f = urllib.urlopen("%s/p-%d?" % (url, i))
        soup = BeautifulSoup("".join([i for i in f]))
        for result in soup.findAll('div', {'class': 'listing-client-line-pg  clearfix', 'id': True}):
            vcard = result.findAll('div', {'class': 'vcard clearfix'})[0]
            nome = find_text(vcard.findAll('h3', {'class': re.compile('org')}))
            cap = find_text(vcard.findAll('span', {'class': 'postal-code'}))
            locality = find_text(vcard.findAll('span', {'class': 'locality'}))
            region = find_text(vcard.findAll('span', {'class': 'region'}))
            address = find_text(vcard.findAll('p', {'class': 'street-address'}))
            tel = find_text(vcard.findAll('p', {'class': 'tel'}))
            fax = find_text(vcard.findAll('p', {'class': 'tel'}), 1)
            category = find_text(result.findAll('p', {'class': 'client-category'}))
            description = find_text(result.findAll('p', {'class': 'txtsnippet'}))
            values = []
            for v in  [clean(nome),
                       clean(address),
                       clean(locality),
                       clean(cap),
                       clean(region),
                       clean(tel),
                       clean(fax),
                       clean(category),
                       clean(description)]:
                values.append(v.encode('ascii', 'ignore'))
            csvwriter.writerow(values)
    return True

if __name__ == '__main__':
    print """
    =================================================
     PagineGialle2CSV by fox (fox91 at anche dot no)
    =================================================
    """
    try:
        while True:
            cosa = raw_input("Cosa: ")
            if not cosa:
                continue
            dove = raw_input("Dove: ")
            if not dove:
                continue
            output = raw_input("Output: ")
            if not output:
                continue
            if cosa and dove and output:
                url = "http://www.paginegialle.it/pgol/4-%s/3-%s" % (cosa, dove)
                res = pagine_gialle_parser(url, output, debug=True)
                if res is True:
                    print "Fatto! :) Salvato tutto in %s" % output
                break
    except KeyboardInterrupt:
        print "AAAARGHHH YOU'RE KILLING ME :((("
    finally:
        print "\nBye, I love you <3"
