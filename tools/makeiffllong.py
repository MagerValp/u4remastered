#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import os.path


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"iffl")
    p.add_argument(u"include")
    p.add_argument(u"files", nargs=u"+")
    args = p.parse_args(argv[1:])
    
    lengths = list()
    with open(args.iffl, "wb") as outfile:
        for filename in args.files:
            with open(filename, "rb") as f:
                data = f.read()
                outfile.write(data)
                lengths.append(len(data))
    
    with open(args.include, "wt", encoding=u"utf-8") as f:
        for i, (filename, length) in enumerate(zip(args.files, lengths)):
            f.write(u"\t.word $%04x\t; $%02x - %s\n" % (length, i, os.path.basename(filename)))

    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
