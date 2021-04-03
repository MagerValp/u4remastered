#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
import argparse
import json
import os.path
import itertools


def encode_string(s, lastbit=True):
    lines = s.split(u"\n")
    for line in lines:
        if len(line) > 16:
            print(u"Line too long: '%s'" % line)
    bytes = list(ord(c) | 0x80 for c in s.replace(u"\n", u"\r"))
    if lastbit:
        bytes[-1] &= 0x7f
    return bytes

def bcd(i):
    return int(u"%d" % i, 16)

def encode_trigger(t):
    return {
        None: 0,
        u"job": 3,
        u"health": 4,
        u"keyword 1": 5,
        u"keyword 2": 6,
    }[t]

CONV_KEYS = [
    u"name",
    u"pronoun",
    u"description",
    u"job",
    u"health",
    u"keyword_response_1",
    u"keyword_response_2",
    u"question",
    u"question_yes_answer",
    u"question_no_answer",
]

def encode_conv(conv):
    strings = list(itertools.chain(*[encode_string(conv[key], lastbit=True) for key in CONV_KEYS]))
    if len(strings) > 0xf5:
        return None
    if len(strings) < 0xf5:
        strings.extend([0] * (0xf5 - len(strings)))
    kw1 = encode_string((conv[u"keyword_1"] + u"    ")[:4], lastbit=False)
    kw2 = encode_string((conv[u"keyword_2"] + u"    ")[:4], lastbit=False)
    trigger = encode_trigger(conv[u"question_trigger"])
    humility = 1 if conv[u"humility_question"] else 0
    turnsaway = bcd(conv[u"turns_away_prob"])
    
    bytelist = strings + kw1 + kw2 + [trigger, humility, turnsaway]
    return bytes(bytelist)

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"talk_json")
    p.add_argument(u"output_dir")
    args = p.parse_args(argv[1:])
    
    with open(args.talk_json, u"rt", encoding=u"utf-8") as f:
        talk = json.load(f)
    
    for i, conv in enumerate(talk):
        with open(os.path.join(args.output_dir, u"tlk_%02x.bin" % i), u"wb") as f:
            f.write(encode_conv(conv))
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
