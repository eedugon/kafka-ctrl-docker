FROM ches/kafka:0.10.1.0

MAINTAINER Luis David Barrios Alfonso (luisdavid.barrios@agsnasoft.com / cyberluisda@gmail.com)

USER root

ADD files/kafka-ctl.sh /bin/
RUN chmod a+x /bin/kafka-ctl.sh

USER kafka

ENTRYPOINT ["/bin/kafka-ctl.sh"]
CMD ["--help"]
