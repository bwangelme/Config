#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys

def main():
    source = sys.argv[1]
    file, ext = os.path.splitext(source)
    target = "{}.out".format(file)
    compiler = "gcc" if ext == ".c" else "g++"
    makefile = """{target}:{source}
	{compiler} -o {target} -g {source}""" \
        .format(**{'target': target, 'source': source, 'compiler': compiler})

    with open("Makefile", "w+") as fd:
        fd.write(makefile)


if __name__ == '__main__':
    if(len(sys.argv) < 2):
        sys.stderr.write("Usage: {} {}".format(sys.argv[0], "main.c"))
        sys.exit(1)
    main()
