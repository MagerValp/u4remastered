#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import os


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)

def printerr8(*args):
    print >>sys.stderr, " ".join(unicode(x).encode(u"utf-8") for x in args)


def cut_card(xstart, bitmap, colors, d800):
    b = list()
    c = list()
    d = list()
    for y in xrange(14):
        boff = y * 320 + xstart * 8
        b.append(bitmap[boff:boff + 10 * 8])
        coff = y * 40 + xstart
        c.append(colors[coff:coff + 10])
        d.append(d800[coff])
    return ("".join(b), "".join(c), "".join(d))


def read_koala(path):
    with open(path, u"rb") as f:
        f.read(2)
        bitmap = f.read(8000)
        colors = f.read(1000)
        d800 = f.read(1000)
        bkg = f.read(1)
    return (bitmap, colors, d800)


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"cards1")
    p.add_argument(u"cards2")
    p.add_argument(u"bitmap")
    p.add_argument(u"colors")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    cards = list()
    bitmap, colors, d800 = read_koala(args.cards1)
    cards.append(cut_card( 0, bitmap, colors, d800))
    cards.append(cut_card(10, bitmap, colors, d800))
    cards.append(cut_card(20, bitmap, colors, d800))
    cards.append(cut_card(30, bitmap, colors, d800))
    bitmap, colors, d800 = read_koala(args.cards2)
    cards.append(cut_card( 0, bitmap, colors, d800))
    cards.append(cut_card(10, bitmap, colors, d800))
    cards.append(cut_card(20, bitmap, colors, d800))
    cards.append(cut_card(30, bitmap, colors, d800))
    
    with open(args.bitmap, u"wb") as f:
        f.write(chr(0x00) + chr(0x40))
        f.write("".join(x[0] for x in cards))
    with open(args.colors, u"wb") as f:
        f.write(chr(0x00) + chr(0x98))
        f.write("".join(x[1] + chr(0) * 4 for x in cards))
        f.write("".join(x[2] + chr(0) * 2 for x in cards))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
