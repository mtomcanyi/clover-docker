FROM store/oracle/serverjre:8
MAINTAINER michal.tomcanyi@cloveretl.com 

ENV CATALINA_HOME=/opt/tomcat TOMCAT_VERSION=8.0.24 CLOVER_VERSION=4.1.2 PATH=$CATALINA_HOME/bin:$PATH 
ENV TOMCAT_URL http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
ENV CLOVER_URL http://www.cloveretl.com/download-file?f=${CLOVER_VERSION}%2Fserver%2Fdeploy%2Ftomcat6only%2FApplication+Files%2Fclover.war 
ENV S3_URL https://s3.amazonaws.com/cloveretl.server.docker/${CLOVER_VERSION}

WORKDIR $CATALINA_HOME

#Install Oracle JDK 8
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list \
#&& echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list \
#&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
#&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && apt-get update && apt-get install -y oracle-java8-installer ca-certificates mc \
#&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Define commonly used JAVA_HOME variable
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install wget
RUN yum -y install \
	wget \
	tar \
	gzip

#Tomcat 8 installation
RUN wget --quiet --no-cookies "$TOMCAT_URL" -O  tomcat.tar.gz \
&& tar -xf tomcat.tar.gz --strip-components=1  \
&& rm tomcat.tar.gz* \
&& rm -rf webapps/examples webapps/docs webapps/ROOT bin/*.bat

#clover.war and configuration files download
RUN \
wget --quiet --no-cookies "$CLOVER_URL" -O  webapps/clover.war \ 
&& mkdir -p "$CATALINA_HOME/cloverconf" "$CATALINA_HOME/sandboxes" \
&& wget --quiet --no-cookies "${S3_URL}/clover.properties" -O cloverconf/clover.properties \
&& wget --quiet --no-cookies "${S3_URL}/setenv.sh" -O bin/setenv.sh \
&& chmod +x bin/setenv.sh

VOLUME sandboxes

#Expose port and run it
EXPOSE 8080 8686

CMD ["bin/catalina.sh", "run"]
