#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import os.path


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"start_bank", type=int)
    p.add_argument(u"save_bank", type=int)
    p.add_argument(u"output")
    p.add_argument(u"files", nargs=u"+")
    args = p.parse_args(argv[1:])
    
    numbanks = dict()
    for path in args.files:
        efsname = os.path.splitext(os.path.basename(path))[0]
        numbanks[efsname] = os.stat(path).st_size / 16384
    
    output = []
    for path in args.files:
        efsname = os.path.splitext(os.path.basename(path))[0]
        output.append(u"%s_numbanks\t= %d" % (efsname, numbanks[efsname]))
    output.append(u"efs_start_bank\t= %d" % args.start_bank)
    bank = 0
    for path in args.files:
        efsname = os.path.splitext(os.path.basename(path))[0]
        output.append(u"%s_bank\t= efs_start_bank + %d" % (efsname, bank))
        bank += numbanks[efsname]
    
    output.append(u"sav_bank\t= %d" % args.save_bank)
    
    output.append(u"")
    with open(args.output, "wt", encoding=u"utf-8") as f:
        f.write(u"\n".join(output))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
