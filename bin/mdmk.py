#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys

def main():
    source = sys.argv[1]
    file, ext = os.path.splitext(source)
    target = "{}.out".format(file)
    compiler = "gcc" if ext == ".c" else "g++"
    std = "c99" if ext == ".c" else "gnu++11"
    makefile = """{target}:{source}
	{compiler} -o {target} -I ~/third_part/include/ -L ~/third_part/lib/ -lgtest -lpthread -g {source} --std={std}

.PHONY: clean
clean:
	rm -f {target}""".format(**{
            'target': target,
            'source': source,
            'compiler': compiler,
            'std': std,
        })

    with open("Makefile", "w+") as fd:
        fd.write(makefile)


if __name__ == '__main__':
    if(len(sys.argv) < 2):
        sys.stderr.write("Usage: {} {}".format(sys.argv[0], "main.c"))
        sys.exit(1)
    main()
