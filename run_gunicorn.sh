#!/bin/bash

# Activate venv
source venv/bin/activate

# Set up execution path
cd lion_app

# Start gunicorn
gunicorn lion_app.wsgi:application --config lion_app/gunicorn_config.py

