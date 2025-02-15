FROM python:3.13.2-alpine3.21 AS builder

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

FROM python:3.13.2-alpine3.21 AS production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
mkdir /app && \
chown -R appuser /app

COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

WORKDIR /app

RUN pip install -U django gunicorn

COPY --chown=appuser:appuser . .

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser

EXPOSE 8000

# CMD ["gunicorn", "todo_project.wsgi:application", "--bind", "0.0.0.0:8000"]
CMD ["gunicorn", "--config", "gunicorn_config.py", "todo_project.wsgi:application"]
# CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
