FROM nginx:alpine

COPY *.html styles.css /usr/share/nginx/html/

EXPOSE 80
