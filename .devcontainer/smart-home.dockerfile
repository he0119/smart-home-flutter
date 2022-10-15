FROM he0119/smart-home:master

WORKDIR /app

RUN echo "python manage.py loaddata users board iot storage" >> ./prestart.sh
