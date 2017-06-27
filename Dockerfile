FROM openshine/kafka:0.10.2.0

MAINTAINER Luis David Barrios Alfonso (cyberluisda@gmail.com)

ADD files/kafka-ctl.sh /bin/
RUN chmod a+x /bin/kafka-ctl.sh

ENTRYPOINT ["/bin/kafka-ctl.sh"]
CMD ["--help"]
