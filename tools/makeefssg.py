#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import os.path


def byte(b):
    return bytes([b])

def word(w):
    return byte(w & 0xff) + byte((w & 0xff00) >> 8)

def encode_file(fileid, length, data):
    return byte(fileid) + byte(0xff) + word(length) + data

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"size", type=int)
    p.add_argument(u"output")
    p.add_argument(u"files", nargs=u"+")
    args = p.parse_args(argv[1:])
    
    files = list()
    for filename in args.files:
        with open(filename, "rb") as f:
            data = f.read()[2:]
            fileid = int(os.path.basename(filename)[1:], 16)
            files.append(encode_file(fileid, len(data), data))
    
    data = b"".join(files)
    pad = b"\xff"
    size = 0x2000 * args.size
    padded_data = data + pad * (size - len(data))
    with open(args.output, "wb") as f:
        for offset in range(0, size, 0x2000):
            f.write(padded_data[offset:offset + 0x2000])
            f.write(pad * 0x2000)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
