FROM store/oracle/serverjre:8
MAINTAINER michal.tomcanyi@cloveretl.com 

# Base container sets JAVA_HOME
ENV CATALINA_HOME=/opt/tomcat TOMCAT_VERSION=8.0.47 CLOVER_VERSION=4.8.0 PATH=$CATALINA_HOME/bin:$PATH 
ENV TOMCAT_URL http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
ENV CLOVER_URL https://www.cloveretl.com/download-file?f=${CLOVER_VERSION}%2Fserver%2Fdeploy%2Ftomcat7-9%2FApplication+Files%2Fclover.war
ENV S3_URL https://s3.amazonaws.com/cloveretl.server.docker/${CLOVER_VERSION}


WORKDIR $CATALINA_HOME

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
