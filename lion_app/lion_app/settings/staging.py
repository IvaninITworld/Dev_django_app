import os
from .base import *

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = True


ALLOWED_HOSTS = [
    "default-lion-svc-lb-fab52-19456190-4c9ebc1a2d05.kr.lb.naverncp.com",  # Staging Load balancer
]

CSRF_TRUSTED_ORIGINS = [
    "http://default-lion-svc-lb-fab52-19456190-4c9ebc1a2d05.kr.lb.naverncp.com/",  # Staging Load balancer"
]
