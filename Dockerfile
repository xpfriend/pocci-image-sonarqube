FROM openjdk:8u141-jdk
MAINTAINER ototadana@gmail.com

ENV SONARQUBE_VERSION 6.5
ENV SONAR_LDAP_PLUGIN_URL https://sonarsource.bintray.com/Distribution/sonar-ldap-plugin/sonar-ldap-plugin-2.2.0.608.jar
ENV SONAR_JAVASCRIPT_PLUGIN_URL https://sonarsource.bintray.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-3.1.1.5128.jar
ENV SONAR_FINDBUGS_PLUGIN_URL https://github.com/SonarQubeCommunity/sonar-findbugs/releases/download/3.5.0/sonar-findbugs-plugin.jar
ENV SONAR_GITLAB_PLUGIN 1.7.0
ENV SONAR_L10N_JA_PLUGIN 1.4-SNAPSHOT

RUN apt-get update \
    && apt-get install -y logrotate vim \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip -P /tmp \
    && unzip /tmp/sonarqube-${SONARQUBE_VERSION}.zip -d /opt \
    && rm -f /tmp/sonarqube-${SONARQUBE_VERSION}.zip \
    && mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonar \
    && cp /opt/sonar/conf/* /tmp \
    && tr -d \\r </tmp/sonar.properties >/opt/sonar/conf/sonar.properties \
    && echo>>/opt/sonar/conf/sonar.properties \
    && tr -d \\r </tmp/wrapper.conf >/opt/sonar/conf/wrapper.conf \
    && echo>>/opt/sonar/conf/wrapper.conf

RUN wget ${SONAR_LDAP_PLUGIN_URL} -P /opt/sonar/extensions/plugins
RUN wget ${SONAR_JAVASCRIPT_PLUGIN_URL} -P /opt/sonar/extensions/plugins
RUN wget ${SONAR_FINDBUGS_PLUGIN_URL} -P /opt/sonar/extensions/plugins
RUN wget http://nexus.talanlabs.com/content/groups/public_release/com/synaptix/sonar-gitlab-plugin/${SONAR_GITLAB_PLUGIN}/sonar-gitlab-plugin-${SONAR_GITLAB_PLUGIN}.jar -P /opt/sonar/extensions/plugins
RUN wget http://xpfriend.com/files/sonar-l10n-ja-plugin-${SONAR_L10N_JA_PLUGIN}.jar -P /opt/sonar/extensions/plugins

COPY ./config/. /config/
RUN mv /config/sonar.logrotate.conf /etc/logrotate.d/sonar
RUN chmod +x /config/*


VOLUME ["/opt/sonar/conf", "/opt/sonar/data", "/opt/sonar/extensions", "/opt/sonar/logs"]
EXPOSE 9000

ENTRYPOINT ["/config/entrypoint"]
CMD ["/opt/sonar/bin/linux-x86-64/sonar.sh", "console"]
