''' Programma che rileva se un file e' in italiano o in inglese '''

from string import lowercase

def conta_lettere(s):
    '''
    funzione che prende in input una stringa e restituisce un dizionario
    con la lettera come chiave e la frequenza della stessa come valore
    '''
    freq = {}
    lung = 0
    s = filtro_accentate(s)
    for c in s.lower():
        if c in lowercase:
            try:
                freq[c] += 1
            except KeyError:
                freq[c] = 1
            finally:
                lung += 1
    for key in freq.keys():
        freq[key] = float(freq[key]) / lung * 100
    return freq

def filtro_accentate(s):
    '''
    funzione che prende in input una stringa e restituisce la stringa con le
    lettere senza accento
    '''
    accentate = [('à', 'a'), ('ò', 'o'), ('è', 'e'), ('ì', 'i'), ('ù', 'u')]
    for l in accentate:
        s = s.replace(l[0], l[1])
    return s

def trigrammi(s):
    '''
    funzione che prende in input una stringa e restituisce un dizionario con
    i trigrammi che compaiono nella stringa come chiave e il numero di
    occorrenze come valore
    '''
    s = " %s " % filtro_accentate(s.lower())
    for c in s:
        if not (c in lowercase or c == " "):
            s = s.replace(c, ' ')

    i = 0
    while i < len(s) - 1:
        if s[i] == " " and s[i+1] == " ":
            s = "".join((s[0:i], s[i+1:]))
            i -= 1
        i += 1

    diz = {}
    for i in range(len(s) - 2):
        trigr = s[i:i+3]
        try:
            diz[trigr] += 1
        except KeyError:
            diz[trigr] = 1
    return diz

def confronto_diz(d1, d2):
    '''
    funzione che prende in input due dizionari e ne restituisce la distanza tra
    0 (diversi) e 1 (uguali)
    '''
    ps = 0.0
    pv1 = 0
    pv2 = 0
    for key in d1.keys():
        if d2.has_key(key) is True:
            ps += d1[key] * d2[key]
        pv1 += d1[key] ** 2
    for key in d2.keys():
        pv2 += d2[key] ** 2
    return ps / ((pv1 ** 0.5) * (pv2 ** 0.5))

freq_ita = { 'a': 11.74,
             'b': 0.92,
             'c': 4.5,
             'd': 3.73,
             'e': 11.79,
             'f': 0.95,
             'g': 1.64,
             'h': 1.54,
             'i': 11.28,
             'j': 0,
             'k': 0,
             'l': 6.51,
             'm': 2.51,
             'n': 6.88,
             'o': 9.83,
             'p': 3.05,
             'q': 0.51,
             'r': 6.37,
             's': 4.98,
             't': 5.62,
             'u': 3.01,
             'v': 2.10,
             'w': 0,
             'x': 0,
             'y': 0,
             'z': 0.49 }

freq_eng = { 'a': 8.167,
             'b': 1.492,
             'c': 2.782,
             'd': 4.253,
             'e': 12.702,
             'f': 2.228,
             'g': 2.015,
             'h': 6.094,
             'i': 6.966,
             'j': 0.153,
             'k': 0.772,
             'l': 4.025,
             'm': 2.406,
             'n': 6.749,
             'o': 7.507,
             'p': 1.929,
             'q': 0.095,
             'r': 5.987,
             's': 6.327,
             't': 9.056,
             'u': 2.758,
             'v': 0.978,
             'w': 2.360,
             'x': 0.150,
             'y': 1.974,
             'z': 0.074 }

if __name__ == '__main__':
    try:
        testo = "".join(open('gpl.it.txt', 'r'))
    except IOError:
        print "Errore nella lettura del file :("
    else:
        freq = conta_lettere(testo)
        eng = confronto_diz(freq, freq_eng)
        ita = confronto_diz(freq, freq_ita)

        if ita > 0.90:
            lingua = "italiano (errore: %f)" % (1 - ita)
        elif eng > 0.90:
            lingua = "inglese (errore: %f)" % (1 - eng)
        else:
            lingua = "sconosciuta (errore italiano: %f - errore inglese: %f)" \
                     % (ita, eng)

        print "Lingua rilevata: %s" % lingua
     
    print "-" * 50
    print trigrammi(testo)
