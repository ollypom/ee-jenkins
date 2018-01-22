FROM alpine:3.7
#FROM alpine:3.2

RUN apk add --no-cache nginx
EXPOSE 80
RUN mkdir -p /run/nginx
COPY myweb /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
