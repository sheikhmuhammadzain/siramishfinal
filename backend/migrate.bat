@echo off
..\venv\Scripts\activate.bat
python manage.py makemigrations
python manage.py migrate
pause