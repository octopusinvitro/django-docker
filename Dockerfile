FROM python:3.10.9-slim-bullseye

RUN useradd -m ubuntu
USER ubuntu
ENV HOME /home/ubuntu
ENV PATH $PATH:$HOME/.local/bin
RUN echo "alias ls='ls --color=auto --group-directories-first -v'" >> ~/.bashrc

ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY --chown=ubuntu ./Pipfile* ./
RUN python3 -m pip install --upgrade pip
RUN pip install pipenv
RUN pipenv install --dev --system

COPY --chown=ubuntu . .
