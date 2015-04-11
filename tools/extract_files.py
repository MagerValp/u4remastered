#!/usr/bin/python
# -*- coding: utf-8 -*-


import os
import sys
import argparse


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)


def decode_hex(s):
    return int(s[1:], 16)

def decode_fileid(s):
    if s:
        return (int(s[0]), int(s[1:], 16))
    else:
        return None

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"filemap")
    p.add_argument(u"disk_images", nargs=4)
    p.add_argument(u"output_dir")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    # Read filemap.
    file_ids = list()
    short_files = [None] * 0x1d
    long_files = [None] * 0x60
    with open(args.filemap, u"r") as f:
        headers = f.readline().decode(u"utf-8").rstrip().split(u"\t")
        for line in f:
            fields = line.decode(u"utf-8").rstrip().split(u"\t")
            filenum = decode_hex(fields.pop(0))
            start = decode_hex(fields.pop(0))
            length = decode_hex(fields.pop(0))
            offset = decode_hex(fields.pop(0))
            name = fields.pop(0)
            files = list(decode_fileid(fields.pop(0)) for x in xrange(4))
            comment = fields.pop(0)
            
            if not name:
                continue
            
            for f in files:
                if f:
                    disk, num = f
                    fileid = disk * 0x0100 + num
                    if fileid not in file_ids:
                        file_ids.append(fileid)
            
            if filenum < 0x40:
                short_files[filenum] = (length, start, offset)
            else:
                long_files[filenum - 0x40] = (length, start, offset)
    
    # Read disk images.
    disk_datas = list()
    for disk_image in args.disk_images:
        with open(disk_image, u"rb") as f:
            disk_datas.append(f.read())
    
    # Create output directory.
    if not os.path.isdir(args.output_dir):
        os.mkdir(args.output_dir)
    
    # Extract files from tables.
    for file_id in file_ids:
        disk_id = ((file_id & 0xf00) >> 8) - 1
        dir_path = os.path.join(args.output_dir)
        disk_data = disk_datas[disk_id]
        file_num = file_id & 0xff
        if file_num < 0x40:
            length, address, offset = short_files[file_num]
        else:
            length, address, offset = long_files[file_num - 0x40]
        data = disk_data[offset:offset + length]
        with open(u"%s/%03x.prg" % (dir_path, file_id), u"wb") as f:
            f.write(chr(address & 0xff))
            f.write(chr(address >> 8))
            f.write(data)
    
    # Extract Britannia map.
    for i in xrange(256):
        map_tile = disk_datas[1][(i + 1) * 256:(i + 2) * 256]
        with open(os.path.join(args.output_dir, u"map_%02x.bin" % i), u"wb") as f:
            f.write(map_tile)
    
    # Extract conversations.
    for i in xrange(256):
        talk = disk_datas[2][(i + 1) * 256:(i + 2) * 256]
        with open(os.path.join(args.output_dir, u"tlk_%02x.bin" % i), u"wb") as f:
            f.write(talk)
    
    # Extract dungeon rooms.
    for i in xrange(176):
        dungeon = disk_datas[3][(i + 1) * 256:(i + 2) * 256]
        with open(os.path.join(args.output_dir, u"dng_%02x.bin" % i), u"wb") as f:
            f.write(dungeon)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
