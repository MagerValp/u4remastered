#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import math


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)

def printerr8(*args):
    print >>sys.stderr, " ".join(unicode(x).encode(u"utf-8") for x in args)



def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"amplitude", type=int)
    p.add_argument(u"output")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    swing_amp = float(args.amplitude) - 0.0000001
    swing_center = swing_amp
    swing_data = list()
    size = 512
    for x in xrange(size):
        swing_data.append(swing_center + swing_amp * math.cos(float(x) * math.pi / float(size / 2)))
    
    output = [
        u"\t.export testsinus",
        u"\t.export testsinus_end",
        u"",
        u"\t.data",
        u"",
        u"\t.align $100",
        u"",
    ]
    
    output.append(u"testsinus:")
    for x in swing_data:
        output.append(u"\t.word %4d" % int(x))
    output.append(u"testsinus_end:")
    
    output.append(u"")
    with open(args.output, u"w") as f:
        f.write((u"\n".join(output)).encode(u"utf-8"))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
