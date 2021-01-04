FROM python:3.9

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY gunicorn.conf.py /gunicorn.conf.py

WORKDIR /app

ENV PYTHONPATH=/app

EXPOSE 80

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-c", "/gunicorn.conf.py", "app.main:app"]
