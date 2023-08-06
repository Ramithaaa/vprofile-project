FROM tomcat:9-jre-11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/Root.war
EXPOSE 8080
CMD ["catalina.sh","run"]