# Copyright (C) Microsoft Corporation

import os

import auth_endpoints
import index_endpoints
import jobs_endpoints
import projects_endpoints
from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from settings_factory import provideSettings

settings = provideSettings()

app = Flask(
    __name__,
    template_folder=os.path.join(os.path.dirname(__file__), "..", "build"),
    static_folder=os.path.join(os.path.dirname(__file__), "..", "build", "static"),
)

app.config["JWT_SECRET_KEY"] = settings.JWT_SECRET
jwt = JWTManager(app)

app.register_blueprint(jobs_endpoints.jobs, url_prefix="/jobs")
app.register_blueprint(projects_endpoints.projects, url_prefix="/projects")
app.register_blueprint(index_endpoints.index, url_prefix="/")
app.register_blueprint(auth_endpoints.authentication, url_prefix="/")
CORS(app, resources={r"/*": {"origins": "*"}})
app.config["CORS_HEADERS"] = "Content-Type"

if __name__ == "__main__":
    app.run(host=settings.LISTENING_URL, port=settings.LISTENING_PORT)
