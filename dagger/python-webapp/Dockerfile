FROM python:3.13-slim

WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir flask==3.1.1

EXPOSE 5000

CMD ["python", "app.py"]
