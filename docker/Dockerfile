# EVE WSPACE MYSQL
#
# VERSION               0.2

FROM ubuntu:12.04
MAINTAINER Papazafeiropoulos Giorgos <g.papazafeiropoulos@gmail.com>

ENV NGINX_HOSTNAME rens
#MYSQL pulled from separate container
ENV MYSQL_USER maptool
ENV MYSQL_PASS changeme
#DJANGO unique key - create a new one!
ENV DJANGO_KEY @o3zk1@4^d3osu-om9-_=(hvr48o*%c+@h3d$%pg2g+ta2g2v(

# DO NOT MODIFY THESE!
# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

#Update packages and install needed.
RUN apt-get -y update
RUN apt-get install -y git-core build-essential python-dev python-pip nginx bzip2 memcached mysql-client libxml2-dev libxslt-dev rabbitmq-server supervisor curl sudo libyaml-dev vim

#Set up nginx as daemon off.
RUN sed -i -e '1idaemon off;' /etc/nginx/nginx.conf

RUN easy_install -U distribute 
RUN pip install virtualenv

# copy supervisor conf
ADD supervisor/conf.d /etc/supervisor/conf.d

ADD evewspace.sh evewspace.sh
RUN chmod +x evewspace.sh

#Set Maptool user
RUN adduser --disabled-password --gecos '' ${MYSQL_USER} && adduser ${MYSQL_USER} sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${MYSQL_USER}
WORKDIR /home/${MYSQL_USER}
RUN mkdir /home/${MYSQL_USER}/static

#Get eve-wspace code
RUN git clone https://github.com/andrewmunro/eve-wspace.git && cd eve-wspace && git checkout docker-improvements

# Concat latest eve mysql dump into single file
RUN curl -O https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2
RUN mkdir evedump && tar xvf mysql-latest.tar.bz2 -C evedump
RUN touch evedump.sql && find ./evedump -type f -name "*.sql" -exec sh -c "cat {} > evedump.sql" \;
RUN rm -rf evedump && rm -rf mysql-latest.tar.bz2

#Get back to root
USER root

#Set up nginx
ADD nginx/evewspace /etc/nginx/sites-available/evewspace
RUN sed -i -e "s/server_name name;/server_name ${NGINX_HOSTNAME};/"	/etc/nginx/sites-available/evewspace
RUN sed -i -e "s/{MYSQL_USER}/${MYSQL_USER}/" /etc/nginx/sites-available/evewspace
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/evewspace /etc/nginx/sites-enabled/evewspace

#Set up celery and gunicorn
RUN sed -i -e "s/{MYSQL_USER}/${MYSQL_USER}/g" /etc/supervisor/conf.d/celery.conf
RUN sed -i -e "s/{MYSQL_USER}/${MYSQL_USER}/g" /etc/supervisor/conf.d/gunicorn.conf
# clean packages
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# start supervisor
EXPOSE 80
ADD entrypoint.sh /entrypoint.sh
ADD evewspace.sh /evewspace.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /evewspace.sh
ENTRYPOINT ["/entrypoint.sh"]