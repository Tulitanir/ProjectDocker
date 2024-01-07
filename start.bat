git submodule update --init --recursive --remote
docker compose up -d --build && echo Интерфейс должен быть доступен по URL: http://localhost:3000
pause