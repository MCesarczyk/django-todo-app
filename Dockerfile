FROM python:3.13.2-alpine3.21

RUN mkdir /app

WORKDIR /app

RUN apk add --update --no-cache \
  gcc\
  libc-dev \
  libffi-dev \
  openssl-dev \
  bash \
  git \
  libtool \
  m4 \
  g++ \
  autoconf \
  automake \
  build-base \
  postgresql-dev

# Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE=1
#Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip
RUN pip install poetry

ADD pyproject.toml poetry.lock ./
RUN poetry install --no-root

COPY . /app/

EXPOSE 8000

CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
