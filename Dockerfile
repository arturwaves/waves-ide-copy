FROM node:10 as dist

ARG COMPILER_PARAM=""
ENV COMPILER_PARAM=$COMPILER_PARAM

RUN find /etc/apt -name "*.list" -type f -exec \
    sed -i \
    -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
    -e 's|http://security.debian.org|http://archive.debian.org/debian-security|g' \
    {} +

RUN apt-get update && apt-get install -y git apt-transport-https software-properties-common
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list 
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
RUN apt-get update 
RUN apt-get -y install sbt openjdk-8-jre
#RUN RUN RUN, why not? :)

COPY . /
RUN sh /scripts/build.sh

FROM nginx:latest

COPY nginx-ide.conf /etc/nginx/conf.d/
COPY --from=dist /dist /usr/share/nginx/dist
RUN nginx -t
