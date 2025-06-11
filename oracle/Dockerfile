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
    && DIR_ORACLE_INSTANT_CLIENT=$(ls -d /opt/oracle/*/ | sed 's:/$::g') \
    && echo $DIR_ORACLE_INSTANT_CLIENT > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

RUN DIR_ORACLE_INSTANT_CLIENT=$(ls -d /opt/oracle/*/ | sed 's:/$::g') \
    && VER_MAY_ORACLE_INSTANT_CLIENT=$(echo $DIR_ORACLE_INSTANT_CLIENT | cut -d "_" -f 2) \
    && VER_MIN_ORACLE_INSTANT_CLIENT=$(echo $DIR_ORACLE_INSTANT_CLIENT | cut -d "_" -f 3) \
    && echo "instantclient,$DIR_ORACLE_INSTANT_CLIENT" | pecl install oci8-3.3.0 \
    && docker-php-ext-enable oci8

RUN DIR_ORACLE_INSTANT_CLIENT=$(ls -d /opt/oracle/*/ | sed 's:/$::g') \
    && VER_MAY_ORACLE_INSTANT_CLIENT=$(echo $DIR_ORACLE_INSTANT_CLIENT | cut -d "_" -f 2) \
    && VER_MIN_ORACLE_INSTANT_CLIENT=$(echo $DIR_ORACLE_INSTANT_CLIENT | cut -d "_" -f 3) \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,$DIR_ORACLE_INSTANT_CLIENT,${VER_MAY_ORACLE_INSTANT_CLIENT}.${VER_MIN_ORACLE_INSTANT_CLIENT} \
    && docker-php-ext-install pdo_oci
