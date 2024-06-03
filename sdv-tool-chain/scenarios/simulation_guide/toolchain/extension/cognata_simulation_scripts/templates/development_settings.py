import os

from base_settings import BaseSettings


class Development(BaseSettings):
    LISTENING_URL = '127.0.0.1'
    LISTENING_PORT = '5000'
