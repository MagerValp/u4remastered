#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import os


def cut_card(xstart, bitmap, colors, d800):
    b = list()
    c = list()
    d = list()
    for y in range(14):
        boff = y * 320 + xstart * 8
        b.append(bitmap[boff:boff + 10 * 8])
        coff = y * 40 + xstart
        c.append(colors[coff:coff + 10])
        d.append(d800[coff])
    return (b"".join(b), b"".join(c), bytes(d))


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
    args = p.parse_args(argv[1:])
    
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
        f.write(b'\x00\x40')
        f.write(b"".join(x[0] for x in cards))
    with open(args.colors, u"wb") as f:
        f.write(b'\x00\x98')
        f.write(b"".join(x[1] + b'\x00' * 4 for x in cards))
        f.write(b"".join(x[2] + b'\x00' * 2 for x in cards))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
