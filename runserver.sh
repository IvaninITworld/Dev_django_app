#!/bin/bash

APP_NAME=lion_app

# git pull
echo "Start to execute git pull"
git pull

# 가상환경 적용 (source)
echo "Start activate venv"
source venv/bin/activate

# runserver
echo "Start execute runserver command"
python3 $APP_NAME/manage.py runserver 0.0.0.0:8000
