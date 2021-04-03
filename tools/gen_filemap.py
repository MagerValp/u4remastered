#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import os.path


def decode_hex(s):
    return int(s[1:], 16)

def decode_fileid(s):
    if s:
        return (int(s[0]), int(s[1:], 16))
    else:
        return None

def diskindex(fileid):
    return fileid[0] - 1

def mapindex(fileid):
    if fileid[1] >= 0x40:
        return fileid[1] - 0x20
    else:
        return fileid[1]

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"filemap")
    p.add_argument(u"output")
    p.add_argument(u"files", nargs=u"+")
    args = p.parse_args(argv[1:])
    
    # Enumerate the GAM IFFL files to get each file's index.
    fileindex = dict()
    for i, fileid in enumerate(args.files):
        disknum = int(fileid[0])
        filenum = int(fileid[1:], 16)
        fileindex[decode_fileid(fileid)] = i
    
    # There is one map table per original disk side.
    table_size = 128
    filemap = [
        [0xff] * table_size,
        [0xff] * table_size,
        [0xff] * table_size,
        [0xff] * table_size,
    ]
    
    # Read filemap.
    with open(args.filemap, u"rt", encoding=u"utf-8") as f:
        headers = f.readline().rstrip().split(u"\t")
        for line in f:
            fields = line.rstrip().split(u"\t")
            filenum = decode_hex(fields.pop(0))
            start = decode_hex(fields.pop(0))
            length = decode_hex(fields.pop(0))
            offset = decode_hex(fields.pop(0))
            name = fields.pop(0)
            #iffl = fields.pop(0).lower().strip().startswith(u"y")
            files = list(decode_fileid(fields.pop(0)) for x in range(4))
            comment = fields.pop(0)
            
            for diskindex, fileid in enumerate(f for f in files):
                if fileid and fileid in fileindex:
                    filemap[diskindex][mapindex(fileid)] = fileindex[fileid]
    
    # Generate assembly source.
    labels = [
        u"prg_filemap",
        u"bri_filemap",
        u"tow_filemap",
        u"und_filemap",
    ]
    
    output = list(u"\t.export %s" % x for x in labels)
    output.extend([
        u"",
        u"",
        u'\t.segment "FILEMAP"',
        u"",
        u"\t.align 256",
        u"",
    ])
    
    for disk, label in enumerate(labels):
        output.append(u"%s:" % label)
        for i, filenum in enumerate(filemap[disk]):
            if i >= 0x20:
                fileid = i + 0x20
            else:
                fileid = i
            output.append(u"\t.byte $%02x\t; %d%02x" % (filenum, disk + 1, fileid))
    
    output.append(u"")
    with open(args.output, "wt", encoding=u"utf-8") as f:
        f.write(u"\n".join(output))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
