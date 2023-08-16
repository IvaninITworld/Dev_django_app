from base import *

SECRET_KEY=""

DEBUG=False


ALLOWED_HOSTS = [
    "lion-lb-18904316-04e720249f4d.kr.lb.naverncp.com", # Prod Load balancer
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-lb-18904316-04e720249f4d.kr.lb.naverncp.com/", # Prod Load balancer
    "http://101.79.14.79/", # Load balancer
]