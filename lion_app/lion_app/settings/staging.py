import os
from .base import *

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = True


ALLOWED_HOSTS = [
    "lion-lb-staging-18975818-470dadb487de.kr.lb.naverncp.com",  # Staging Load balancer
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-lb-staging-18975818-470dadb487de.kr.lb.naverncp.com/",  # Staging Load balancer
    "http://223.130.145.30/",  # Staging Load balancer
]
