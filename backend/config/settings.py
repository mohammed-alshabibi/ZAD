"""Django settings for the ZAD API. Secrets and the database URI come from backend/.env (CLAUDE.md §13)."""

import os
from pathlib import Path

from django.core.exceptions import ImproperlyConfigured

BASE_DIR = Path(__file__).resolve().parent.parent


def env(name, default=None):
    value = os.environ.get(name, default)
    if value is None:
        raise ImproperlyConfigured(f"Set {name} in backend/.env")
    return value


SECRET_KEY = env("DJANGO_SECRET_KEY")
DEBUG = env("DJANGO_DEBUG", "0") == "1"
# Phones reach the laptop by its Wi-Fi IP, so any host is accepted in development.
ALLOWED_HOSTS = ["*"] if DEBUG else env("DJANGO_ALLOWED_HOSTS", "").split(",")

INSTALLED_APPS = [
    "django_mongodb_backend",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"

DATABASES = {
    "default": {
        "ENGINE": "django_mongodb_backend",
        "HOST": env("MONGODB_URI"),
        "NAME": env("MONGODB_DB", "zad"),
    },
}
DEFAULT_AUTO_FIELD = "django_mongodb_backend.fields.ObjectIdAutoField"

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"  # stored in UTC, shown as Asia/Muscat in the app
USE_TZ = True
