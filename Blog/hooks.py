#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import threading
import os

import tornado.ioloop
import tornado.web
import logging
import tornado.options
import subprocess

from tornado.options import define, options


define("port", default=1111, help="run on the given port", type=int)

_PWD = os.path.abspath(os.path.dirname(__file__))
lock = threading.Lock()


def execute_cmd(args, cwd=None, timeout=30):
    if isinstance(args, str): args = [args]
    try:
        with subprocess.Popen(args, stdout=subprocess.PIPE, cwd=cwd) as proc:
            try:
                output, unused_err = proc.communicate(timeout=timeout)
            except:
                proc.kill()
                raise
            retcode = proc.poll()
            if retcode:
                raise subprocess.CalledProcessError(retcode, proc.args, output=output)
            return output.decode('utf-8', 'ignore') if output else ''
    except Exception as ex:
        logging.error('EXECUTE_CMD_ERROR: %s', ' '.join(str(x) for x in args))
        raise ex


def build():
    with lock:
        logging.info("BUILDING NOW...")
        resp = execute_cmd(os.path.join(_PWD, 'build.sh'), cwd=_PWD, timeout=600)
        logging.info(resp)


class UpdateHandler(tornado.web.RequestHandler):
    def get(self):
        self.post()

    def post(self):
        self.set_status(200)
        self.write(b"OK")
        threading.Thread(target=build).start()


def make_app():
    return tornado.web.Application(
        handlers=[(r"/update", UpdateHandler),],
        debug=True,
    )


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.INFO)
    tornado.options.parse_command_line()
    app = make_app()
    logging.info("Starting the hooks server at 127.0.0.1:%s", options.port)
    app.listen(options.port)
    tornado.ioloop.IOLoop.current().start()
