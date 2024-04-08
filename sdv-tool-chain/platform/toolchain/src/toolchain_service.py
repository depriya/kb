#! /usr/bin/env python3

"""
Copyright (C) Microsoft Corporation.

Toolchain service.

Ref: https://www.tornadoweb.org/en/stable/guide/running.html
"""

import asyncio
import os
from functools import reduce

import tornado
from core.application import Application


class MainHandler(tornado.web.RequestHandler):
    """Handler for the main route."""

    def get(self):  # noqa: D102
        self.finish("Toolchain service. Call GET /extension/ to see extension routes.")  # type: ignore


class ExtensionHandler(tornado.web.RequestHandler):
    """Handler for the extension route."""

    def initialize(self) -> None:  # noqa: D102
        toolchain_application = Application(os.path.abspath(__file__))
        toolchain_application.load_extensions()
        self.__toolchain_application = toolchain_application

    def get(self, extension_name: str = ""):  # noqa: D102
        if not extension_name:
            self.finish(  # type: ignore
                {ext.name: ext.description for ext in self.__toolchain_application.extensions.collect_extensions("")}
            )
            return

        try:
            extension = self.__toolchain_application.extensions.get_extension_by_alias(extension_name)
        except KeyError:
            self.set_status(404)
            self.finish({"error": f"Extension '{extension_name}' not found."})  # type: ignore
            return

        self.finish({extension_name: extension.description})  # type: ignore

    def post(self, extension_name: str = ""):  # noqa: D102
        if not extension_name:
            self.set_status(400)
            self.finish({"error": "Extension name is required."})  # type: ignore
            return

        try:
            extension = self.__toolchain_application.extensions.get_extension_by_alias(extension_name)
        except KeyError:
            self.set_status(404)
            self.finish({"error": f"Extension '{extension_name}' not found."})  # type: ignore
            return

        self.application.log_request(self)
        data: dict[str, str] = tornado.escape.json_decode(self.request.body)

        # Convert the data to a list of strings because the extension expects a list of strings.
        args: list[str] = list(reduce(lambda x, y: x + list(y), data.items(), list[str]()))
        extension.execute(args)
        self.finish()  # type: ignore


def make_app():
    """Create and return a Tornado web application."""
    debug = os.environ.get("DEBUG", "false").lower() == "true"

    return tornado.web.Application(
        [
            (r"/", MainHandler),
            (r"/extension/(.*)", ExtensionHandler),
            (r"/extension", ExtensionHandler),
        ],
        debug=debug,
    )


async def main():
    """Run Main function for the toolchain service."""
    app = make_app()
    app.listen(8888)
    shutdown_event = asyncio.Event()
    await shutdown_event.wait()


if __name__ == "__main__":
    asyncio.run(main())
