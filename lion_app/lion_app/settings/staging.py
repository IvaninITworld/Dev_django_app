import os
from .base import *

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = True


ALLOWED_HOSTS = [
    "lion-lb-staging-18975818-470dadb487de.kr.lb.naverncp.com",  # Staging Load balancer
    "default-lion-svc-lb-fab52-19456190-4c9ebc1a2d05.kr.lb.naverncp.com",
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-lb-staging-18975818-470dadb487de.kr.lb.naverncp.com/",  # Staging Load balancer
    "http://223.130.145.30/",  # Staging Load balancer
    "http://default-lion-svc-lb-fab52-19456190-4c9ebc1a2d05.kr.lb.naverncp.com/",  # Staging Load balancer"
]
