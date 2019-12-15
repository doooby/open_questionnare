FROM app:production

COPY assets/* public/assets/
COPY frontend/build/* public/