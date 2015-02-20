FROM        debian:wheezy
ADD jenkins-ci.org.key /jenkins-ci.org.key
RUN cat /jenkins-ci.org.key | apt-key add - && \
  echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" >> /etc/apt/sources.list.d/jenkins.list && \
  apt-get update && \
  RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  openjdk-7-jre-headless \
  unzip \
  jenkins && \
  rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_LOGS /var/log/jenkins
ENV JENKINS_PLUG ${JENKINS_HOME}/plugins
ENV JENKINS_PERSIST /persist/jenkins
ENV JENKINS_WAR /usr/share/jenkins/jenkins.war

ADD install_plugins.sh /install_plugins.sh
ADD jenkins.plugins /jenkins.plugins
ADD config.xml /config.xml
ADD jenkins.sh /jenkins.sh

RUN /install_plugins.sh /plugins /jenkins.plugins

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT [ "/jenkins.sh"]
CMD []
