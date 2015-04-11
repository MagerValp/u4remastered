#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys
import argparse
import re


def print8(*args):
    print " ".join(unicode(x).encode(u"utf-8") for x in args)


class PatcherError(Exception):
    pass

class Patcher(object):
    """Perform in-memory binary patching."""
    
    def __init__(self, source_path):
        super(Patcher, self).__init__()
        with open(source_path, "rb") as f:
            self.data = list(ord(c) for c in f.read())
        self.offset = 0
        self.match_len = 0
    
    def patch(self, patch_path):
        """Read and execute patch commands from file."""
        
        with open(patch_path) as f:
            for i, line in enumerate(f):
                self.execute(line.decode(u"utf-8"), i + 1)
    
    re_comment = re.compile(r'\s*#.*$')
    re_command = re.compile(r'\b(?P<command>\w+)\((?P<args>[^)]*)\)')
    
    def parse_args(self, args):
        argvalues = list()
        in_quotes = False
        hex_value = None
        for char in args:
            if char == u'"':
                if in_quotes:
                    argvalues.extend(ord(x) | 0x80 for x in quoted_string)
                else:
                    quoted_string = u""
                in_quotes = not in_quotes
            else:
                if in_quotes:
                    quoted_string += char
                elif char == u" ":
                    if hex_value is not None:
                        argvalues.append(hex_value)
                        hex_value = None
                elif ("0" <= char <= "9") or ("a" <= char.lower() <= "f"):
                    if hex_value is None:
                        hex_value = int(char, 16)
                    else:
                        hex_value = hex_value * 16 + int(char, 16)
        if hex_value is not None:
            argvalues.append(hex_value)
        return argvalues
    
    def execute(self, line, linenum):
        line = self.re_comment.sub(u"", line).lstrip().rstrip()
        if not line:
            return
        try:
            for command in self.re_command.finditer(line):
                cmd = command.group(u"command")
                try:
                    args = self.parse_args(command.group(u"args"))
                except ValueError as e:
                    raise PatcherError(u"Syntax error")
                if cmd == u"offset":
                    self.cmd_offset(args)
                elif cmd == u"match":
                    self.cmd_match(args)
                elif cmd == u"replace":
                    self.cmd_replace(args)
                elif cmd == u"truncate":
                    self.cmd_truncate(args)
                elif cmd == u"insert":
                    self.cmd_insert(args)
                elif cmd == u"append":
                    self.cmd_append(args)
                elif cmd == u"delete":
                    self.cmd_delete(args)
                else:
                    raise PatcherError(u"Unknown command '%s'" % cmd)
        except PatcherError as e:
            raise PatcherError(u"Line %d: %s" % (linenum, unicode(e)))
    
    def cmd_offset(self, args):
        if len(args) != 1:
            raise PatcherError(u"Offset expected value")
        self.offset = args[0]
        if self.offset < 0 or self.offset > len(self.data):
            raise PatcherError(u"Offset out of range")
    
    def cmd_match(self, args):
        self.match_len = 0
        if len(args) < 1:
            raise PatcherError(u"Match expected values")
        try:
            for i, byte in enumerate(args):
                if self.data[self.offset + i] != byte:
                    raise PatcherError(u"Match failed at offset %04x" % (self.offset + i))
        except IndexError:
            raise PatcherError(u"Match out of range")
        self.match_len = len(args)
    
    def cmd_replace(self, args):
        if len(args) != self.match_len:
            raise PatcherError(u"Replace expected %d matched bytes" % len(args))
        try:
            for i, byte in enumerate(args):
                self.data[self.offset + i] = byte
        except IndexError:
            raise PatcherError(u"Replace out of range")
    
    def cmd_truncate(self, args):
        if len(args) != 1:
            raise PatcherError(u"Truncate expected value")
        self.offset = args[0]
        if self.offset > len(self.data):
            raise PatcherError(u"Truncate out of range")
        del self.data[self.offset:]
    
    def cmd_insert(self, args):
        if len(args) < 1:
            raise PatcherError(u"Insert expected values")
        self.data[self.offset:self.offset] = args
    
    def cmd_append(self, args):
        if len(args) < 1:
            raise PatcherError(u"Append expected values")
        self.data.extend(args)
    
    def cmd_delete(self, args):
        self.match_len = 0
        if len(args) < 1:
            raise PatcherError(u"Delete expected values")
        try:
            for i, byte in enumerate(args):
                if self.data[self.offset + i] != byte:
                    raise PatcherError(u"Delete failed match at offset %04x" % (self.offset + i))
        except IndexError:
            raise PatcherError(u"Delete out of range")
        del self.data[self.offset:self.offset + len(args)]
    
    def save(self, target_path):
        """Saved patched file."""
        
        with open(target_path, "wb") as f:
            f.write("".join(chr(c) for c in self.data))


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"source")
    p.add_argument(u"patch")
    p.add_argument(u"target")
    args = p.parse_args([x.decode(u"utf-8") for x in argv[1:]])
    
    try:
        patcher = Patcher(args.source)
        patcher.patch(args.patch)
        patcher.save(args.target)
    except PatcherError as e:
        print >>sys.stderr, unicode(e).encode(u"utf-8")
        return 1
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
