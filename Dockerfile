FROM jenkins/jenkins:jdk11

ENV JENKINS_DIR /usr/share/jenkins/ref

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false \
                -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York \
                -XX:MaxRAMPercentage=50

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && export TERM=linux \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common python-pip nodejs build-essential postgresql-client-9.6 zip \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && systemctl enable docker \
    && usermod -aG docker jenkins \
    && curl -L https://github.com/digitalocean/doctl/releases/download/v1.45.0/doctl-1.45.0-linux-amd64.tar.gz -o /opt/doctl-cli.tar.gz \
    && mkdir -p /opt/doctl-cli/ \
    && tar -xzf /opt/doctl-cli.tar.gz -C /opt/doctl-cli \
    && ln -s /opt/doctl-cli/doctl /usr/bin/doctl \
    && rm -f /opt/doctl-cli.tar.gz \
    && curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/bin/jq \
    && chmod +x /usr/bin/jq \
    && curl -L https://golang.org/dl/go1.15.linux-amd64.tar.gz -o /opt/go1.15.linux-amd64.tar.gz \
    && mkdir -p /opt/go-1.15 \
    && tar -xzf /opt/go1.15.linux-amd64.tar.gz -C /opt/go-1.15 \
    && ln -s /opt/go-1.15/go/bin/go /usr/bin/go \
    && rm -f /opt/go1.15.linux-amd64.tar.gz

USER jenkins

COPY plugins.txt $JENKINS_DIR/plugins.txt
RUN /usr/local/bin/install-plugins.sh < $JENKINS_DIR/plugins.txt

COPY init.groovy.d $JENKINS_DIR/init.groovy.d/
