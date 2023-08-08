FROM python:3.11-alpine
LABEL likelion.web.backendauthor="Ivan kim <xormrdlsrks2@gmail.com>"

ARG APP_HOME=/app

# 파이썬이 표준출력과 표준에러출력을 버퍼링 하지 않도록 설정
ENV PYTHONUNBUFFERED 1

# 파이썬이 .pyc 바이트코드파일을 작성하지 않도록 설정
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_HOME}

# 패키지들은 자주 바뀌지 않기 때문에 인스톨을 따로 가져가는게 좋다.
# 만약 전체 카피로만 requirements 를 가져오게 되면 코드가 수정되었을 때
# 다시 인스톨을 해줘야하는 일이 발생하기 때문에 따로 이미지 레이어를 쌓아준다.
COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . ${APP_HOME}

COPY ./scripts/start /start
RUN sed -i 's/\r$//g' /start
# \r : 캐리지 리턴
RUN chmod +x /start

COPY ./scripts/entrypoint /entrypoint
# entrypoint 파일 실행
RUN sed -i 's/\r$//g' /entrypoint
# \r : 캐리지 리턴
RUN chmod +x /entrypoint


# RUN python3 manage.py migrate -> entypoint 스크립트로 대체

RUN if [ -e /var/www/html/static ]; then rm -rf /var/www/html/static; fi
# 정적파일을 긁어다가 root 로 보내줘야함
RUN python3 manage.py collectstatic -c

# CMD ["gunicorn", "lion_app.wsgi:application", "--config", "lion_app/gunicorn_config.py"] -> start 스크립트로 대체

ENTRYPOINT [ "/entrypoint" ]
CMD [ "python", "--version" ]