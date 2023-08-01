#!/bin/bash

# Set up execution path
cd lion_app

# Activate venv
source venv/bin/activate

# Start gunicorn
gunicorn lion_app.wsgi:application --config lion_app/gunicorn_config.py

