FROM fusio/fusio
RUN apt-get update && apt-get -y install \
    libaio1

RUN mkdir /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip \
    && unzip -o /opt/oracle/instantclient-basic-linuxx64.zip -d /opt/oracle \
    && unzip -o /opt/oracle/instantclient-sdk-linuxx64.zip -d /opt/oracle \
    && rm -rf /opt/oracle/*.zip \
    && ln -s /usr/local/instantclient_23_8 /usr/local/instantclient

RUN echo /usr/local/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

RUN echo "instantclient,/usr/local/instantclient" | pecl install oci8 \
    && docker-php-ext-enable oci8

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,23.8 \
    && docker-php-ext-install pdo_oci
