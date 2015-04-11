#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import os.path


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"iffl")
    p.add_argument(u"include")
    p.add_argument(u"files", nargs=u"+")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    lengths = list()
    with open(args.iffl, "wb") as outfile:
        for filename in args.files:
            with open(filename, "rb") as f:
                data = f.read()
                outfile.write(data)
                lengths.append(len(data))
    
    with open(args.include, "w") as f:
        for i, (filename, length) in enumerate(zip(args.files, lengths)):
            f.write(u"\t.word $%04x\t; $%02x - %s\n" % (length, i, os.path.basename(filename)))

    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
