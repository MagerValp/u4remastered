#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)

def printerr8(*args):
    print >>sys.stderr, " ".join(unicode(x).encode(u"utf-8") for x in args)


CRT_HEADER_SIZE = 0x40
CRT_VERSION = 0x0100
CRT_HWTYPE_EASYFLASH = 0x20
CHIP_TYPE_FLASH = 0x0002


def byte(b):
    return chr(b)

def word(w):
    return byte((w & 0xff00) >> 8) + byte(w & 0xff)

def longword(l):
    return word((l & 0xffff0000) >> 16) + word(l & 0xffff)

def padstr(s, l):
    return s[:l] + "\x00" * (l - len(s))

def ef_crt_header(name):
    return "".join([
        "C64 CARTRIDGE   ",
        longword(CRT_HEADER_SIZE),
        word(CRT_VERSION),
        word(CRT_HWTYPE_EASYFLASH),
        byte(0x01),
        byte(0x00),
        word(0x0000),
        word(0x0000),
        word(0x0000),
        padstr(name.encode(u"ascii"), 0x20)
    ])

def ef_chip_bank(data, banknum, loadaddr):
    if data == "\xff" * len(data):
        return ""
    return "".join([
        "CHIP",
        longword(len(data) + 0x10),
        word(CHIP_TYPE_FLASH),
        word(banknum),
        word(loadaddr),
        word(len(data)),
        data,
    ])

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"input")
    p.add_argument(u"output")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    with open(args.input, u"rb") as f:
        data = f.read()
    
    if len(data) % 0x4000 != 0:
        printerr8(u"input must be a multiple of $4000 bytes long")
        return 1
    
    output = [ef_crt_header(u"Ultima IV Remastered")]
    for banknum, offset in enumerate(xrange(0, len(data), 0x4000)):
        bank = data[offset:offset + 0x4000]
        output.append(ef_chip_bank(bank[:0x2000], banknum, 0x8000))
        output.append(ef_chip_bank(bank[0x2000:], banknum, 0xa000))
    
    with open(args.output, u"wb") as f:
        for data in output:
            f.write(data)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
