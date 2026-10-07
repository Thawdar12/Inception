FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY tools/script.sh /usr/local/bin/script.sh

CMD ["/usr/local/bin/script.sh"]