# builder image
FROM alpine:latest

ENV HUGO_VERSION 0.88.1

LABEL description="gohugo build"
LABEL version="1.0"
LABEL maintainer="jholdstock@decred.org"

WORKDIR /tmp

RUN apk update && apk upgrade
RUN apk add --no-cache bash wget libc6-compat g++
RUN wget -q https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo_extended_"$HUGO_VERSION"_Linux-64bit.tar.gz
RUN tar xz -C /usr/local/bin -f hugo_extended_"$HUGO_VERSION"_Linux-64bit.tar.gz

WORKDIR /root

COPY . /root/

# Remove old hugo output before building
RUN rm -rf public resources

# Build site
RUN hugo --buildFuture

# Serve image (stable nginx version)
FROM nginx:1.20

LABEL description="dcrblog server"
LABEL version="1.0"
LABEL maintainer="jholdstock@decred.org"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=0 /root/public/ /usr/share/nginx/html
