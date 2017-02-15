FROM wurstmeister/kafka:0.10.1.1

MAINTAINER Luis David Barrios Alfonso (luisdavid.barrios@agsnasoft.com / cyberluisda@gmail.com)

ADD files/kafka-ctl.sh /bin/
RUN chmod a+x /bin/kafka-ctl.sh

ENTRYPOINT ["/bin/kafka-ctl.sh"]
CMD ["--help"]
