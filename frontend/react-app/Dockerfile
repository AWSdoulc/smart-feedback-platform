# Basis-Image
FROM node:18-alpine

# Arbeitsverzeichnis
WORKDIR /react-app

# Abhängigkeiten
COPY package.json ./
COPY vite.config.js ./
RUN npm install

# Code kopieren
COPY . .

# Build ausführen
RUN npm run build

# Statischer Webserver
RUN npm install -g serve
CMD ["serve", "-s", "dist"]

EXPOSE 3000
