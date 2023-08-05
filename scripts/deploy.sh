#!/bin/bash

# Required package install
echo "apt-get update execution"
sudo apt-get update 

echo "apt-get install curl execution"
sudo apt-get install -y curl

echo "apt-get install docker execution"
sudo apt-get install -y docker.io docker-compose

# git clone
echo "Start to clone"
git clone https://github.com/IvaninITworld/Dev_django_app.git dev_django_app
cd dev_django_app

# venv 설치
echo "Start to install venv"
sudo apt-get update
sudo apt install -y python3.8-venv

# venv 구성
echo "Start to make venv"
python3 -m venv venv

# 가상환경 작동
echo "Start to activate venv"
source venv/bin/activate

# pip install
echo "start to install requirements"
pip install -r requirements.txt

# # runserver 기존작업에 제외 -> nginx로 서버를 띄울거니까
# echo "Start to runserver"
# cd lion_app
# python3 manage.py runserver 0.0.0.0:8000



