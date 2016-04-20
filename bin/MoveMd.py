#!/usr/bin/env python3
# encoding: utf-8

import os


def write_file(dest_dir, source_file, title, tags):
    dest_file = os.path.join(dest_dir, title)
    add_string = """---
title: '%s'
date: 2016-04-10 10:56:54
tags: %s
---

__摘要__: 这是一篇关于%s的文章，主要介绍%s
<!-- more -->
""" % (title, tags, tags, title[:-3])
    sfd = open(source_file)
    text = sfd.read()
    sfd.close()
    print('Read text from %s' % source_file)

    dfd = open(dest_file, 'w+')
    dfd.write(add_string)
    dfd.write(text)
    dfd.close()
    print('Write [%s, %s] to %s' % (title, tags, dest_file))


def main():
    ReadingNotes = './ReadingNotes'
    HexoSourcePosts = './blog/source/_posts'
    find_cmd = """
        find %s -name "*.md"
        """ % ReadingNotes
    lines = os.popen(find_cmd).read().strip()
    for line in lines.split('\n'):
        items = line.split('/')
        if len(items) == 4:
            tag = items[-2]
            title = items[-1]
            write_file(HexoSourcePosts, line, title, tag)

if __name__ == '__main__':
    main()
