FROM fusio/fusio
RUN apt-get update && apt-get -y install libaio1t64

ENV MAJOR_ORACLE_INSTANT_CLIENT=23
ENV MINOR_ORACLE_INSTANT_CLIENT=26
ENV DIR_ORACLE_INSTANT_CLIENT="/opt/oracle/instantclient_23_26"

RUN mkdir /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip \
    && unzip -o /opt/oracle/instantclient-basic-linuxx64.zip -d /opt/oracle \
    && unzip -o /opt/oracle/instantclient-sdk-linuxx64.zip -d /opt/oracle \
    && rm -rf /opt/oracle/*.zip \
    && echo $DIR_ORACLE_INSTANT_CLIENT > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

RUN echo "instantclient,$DIR_ORACLE_INSTANT_CLIENT" | pecl install oci8 \
    && docker-php-ext-enable oci8

RUN pecl install pdo_oci \
    && docker-php-ext-enable pdo_oci \
