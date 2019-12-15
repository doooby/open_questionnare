FROM app:production

COPY www/* public/
COPY frontend/build/* public/
