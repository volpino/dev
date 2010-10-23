"""
Project Euler level 17

How many letters are needed to write all the numbers from 1 to 1000 in english?
"""

n = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
dec = ["ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
teen = ["eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]

l = []
for i in range(1, 1000):
    r = ""
    h = i / 100
    d = (i % 100) / 10
    u = i - h*100 - d*10
    if h > 0:
        r +=n[h-1] + "hundred"
        if d > 0 or u > 0:
            r += "and"
    if d == 1 and u > 0:
        r += teen[u-1]
    if d == 1 and u == 0:
        r += dec[0]
    if d > 1:
        r += dec[d-1]
    if u > 0 and d != 1:
        r += n[u-1]
    print i, r
    l.append(r)
l.append("onethousand")
l1 = [len(x) for x in l]
print sum(l1)
