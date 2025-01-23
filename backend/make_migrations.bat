@echo off
call ..\venv\Scripts\activate
python manage.py makemigrations food
python manage.py migrate