#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import subprocess
import tempfile
import os


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"input")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    with open(args.input, u"rb") as f:
        data = f.read()
    
    fh, tempfname = tempfile.mkstemp(suffix=u"bin")
    os.close(fh)
    
    with open(tempfname, "wb") as f:
        f.write("".join(chr(ord(x) ^ 0x80) for x in data))
    
    try:
        p = subprocess.Popen([u"/usr/bin/strings",
                              u"-n", u"2",
                              u"-t", u"x",
                              tempfname],
                             stdout=subprocess.PIPE)
        out, err = p.communicate(None)
    finally:
        os.unlink(tempfname)
    
    for line in out.splitlines():
        offsetstr, _, value = line.partition(" ")
        offset = int(offsetstr, 16)
        print 'offset(%04x) match%-20s replace("%s")' % (offset,
                                                         '("%s")' % value,
                                                         value)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
