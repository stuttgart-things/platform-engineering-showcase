# Define the app sdk base image
ARG APP_SDK_IMAGE=shuffle-app_sdk
ARG APP_SDK_VERSION=0.0.25-a3.22.1-p3.13.7

FROM ${APP_SDK_IMAGE}:${APP_SDK_VERSION} AS base

# Builder stage for dependencies
FROM base AS builder

# Install alpine build tools for compiling Python deps

RUN apk --no-cache add --update \
    alpine-sdk \
    libffi \
    libffi-dev \
    musl-dev \
    openssl-dev \
    postgresql-libs

# Install all pip packages into a staging dir
RUN mkdir /install
WORKDIR /install
COPY requirements.txt /requirements.txt

RUN pip3 install --prefix="/install" shuffle_sdk==0.0.18 -r /requirements.txt

# Final runtime image

FROM base
COPY --from=builder /install /usr/local

WORKDIR /app
CMD ["python", "app.py", "--log-level", "DEBUG"]