#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import json
import os
from collections import defaultdict
import imagearray


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)

def printerr8(*args):
    print >>sys.stderr, " ".join(unicode(x).encode(u"utf-8") for x in args)


vic_luminance = [0, 15, 4, 11, 5, 9, 1, 14, 6, 2, 10, 3, 8, 13, 7, 12]

def hires_char(image):
    color_counts = defaultdict(int)
    for y in xrange(8):
        for x in xrange(8):
            color_counts[image.get_pixel(x, y)] += 1
    if len(color_counts) > 2:
        return None
    elif len(color_counts) == 1:
        bg = color_counts.keys()[0]
        fg = 0 if bg else 1
    else:
        bg, fg = sorted(color_counts.keys(), cmp=lambda x,y: cmp(vic_luminance[x], vic_luminance[y]))
    bytes = list()
    for y in xrange(8):
        byte = 0
        bit = 0x80
        for x in xrange(8):
            if image.get_pixel(x, y) == fg:
                byte |= bit
            bit >>= 1
        bytes.append(byte)
    return (bytes, fg, bg)


def hires_tile(image):
    bitmap = list()
    colors = list()
    for y in xrange(0, 16, 8):
        for x in xrange(0, 16, 8):
            char_image = image.copy(x, y, 8, 8)
            try:
                bytes, fg, bg = hires_char(char_image)
            except TypeError:
                return None
            bitmap.extend(bytes)
            colors.append((fg << 4) | bg)
    return (bitmap, colors)


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"png")
    p.add_argument(u"tileset")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    image = imagearray.ImageArray.load(args.png)
    tiles = list()
    for tile_num in xrange(256):
        tile_x = tile_num & 0x0f
        tile_y = tile_num >> 4
        tile_image = image.copy(tile_x * 16, tile_y * 16, 16, 16)
        tile = hires_tile(tile_image)
        if tile is None:
            printerr8(u"encoding error in tile %02x" % tile_num)
            return 1
        tiles.append(tile)
    
    with open(args.tileset, u"wb") as f:
        for (bitmap, colors) in tiles:
            f.write("".join(chr(x) for x in bitmap[:16]))
        for (bitmap, colors) in tiles:
            f.write("".join(chr(x) for x in bitmap[16:]))
        f.write("".join(chr(x) for x in [colors[0] for (bitmap, colors) in tiles]))
        f.write("".join(chr(x) for x in [colors[1] for (bitmap, colors) in tiles]))
        f.write("".join(chr(x) for x in [colors[2] for (bitmap, colors) in tiles]))
        f.write("".join(chr(x) for x in [colors[3] for (bitmap, colors) in tiles]))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
