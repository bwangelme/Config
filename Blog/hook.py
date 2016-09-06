#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import tornado.ioloop
import tornado.web


class UpdateHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("get")

    def post(self):
        self.write("post")


def make_app():
    return tornado.web.Application([
        (r"/update", UpdateHandler),
    ])


if __name__ == '__main__':
    app = make_app()
    app.listen(1111)
    tornado.ioloop.IOLoop.current().start()
