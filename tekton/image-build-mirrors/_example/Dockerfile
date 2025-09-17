ARG APP_SDK_IMAGE=shuffle-app_sdk
ARG APP_SDK_VERSION=0.0.25-a3.22.1-p3.13.7

FROM ${APP_SDK_IMAGE}:${APP_SDK_VERSION} AS base

# Builder stage
FROM base AS builder
RUN apk --no-cache add \
    alpine-sdk=2.4.5-r1 \
    libffi=3.4.2-r1 \
    libffi-dev=3.4.2-r1 \
    musl-dev=1.2.4-r1 \
    openssl-dev=3.1.3-r0 \
    postgresql-libs=15.3-r0

WORKDIR /install
COPY requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir --prefix="/install" shuffle_sdk==0.0.18 -r /requirements.txt

# Final runtime image
FROM base
COPY --from=builder /install /usr/local
WORKDIR /app
CMD ["python", "app.py", "--log-level", "DEBUG"]
