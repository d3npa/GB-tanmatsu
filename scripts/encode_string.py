#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re

def load_tiles(charmap):
        with open("code/globals.z80.asm", "r") as file:
                for line in file:
                        if re.match("    db  .* ; .* \|", line):
                                char = line[95:-1]
                                offset = line[89:92]
                                # print("%s | %s" % (offset, char))
                                charmap.update({char : offset})

charmap = {"\0" : "$FF", "\n" : "$FE", "\r" : "$FD"}
load_tiles(charmap)

def encode(string):
        string = string
        output = "    db "
        dakuten = "がぎぐげごだぢづでどざじずぜぞばびぶべぼガギグゲゴダヂヅデドザジズゼゾハビブベボ"
        handakuten = "ぱぴぷぺぽパピプペポ"
        for char in string:
                if char in "?": 
                        char = "？"
                if char in "!": 
                        char = "！"
                if char in "　 ": 
                        char = "空"
                if char in dakuten:
                        char = chr(ord(char) - 1)
                        output += charmap["゛"] + ", "
                if char in handakuten:
                        char = chr(ord(char) - 2)
                        output += charmap["゜"] + ", "
                if char in charmap:
                        output += charmap[char] + ", "
                else:
                        output += charmap["空"] + ", "
        output += "$FF ; " + string.replace("\r", "\\r").replace("\n", "\\n")
        return output

print(encode("   がぞう ひょうじ\r\n   /bin/shを じっこう\r\n"))
