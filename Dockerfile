FROM jenkins/jenkins:jdk11

ENV JENKINS_DIR /usr/share/jenkins/ref

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false \
                -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York \
                -XX:MaxRAMPercentage=50

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && export TERM=linux \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg gnupg2 lsb-release software-properties-common python3-pip nodejs gcc g++ make zip \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && systemctl enable docker \
    && usermod -aG docker jenkins \
    && curl -L https://github.com/digitalocean/doctl/releases/download/v1.69.0/doctl-1.69.0-linux-amd64.tar.gz -o /opt/doctl-cli.tar.gz \
    && mkdir -p /opt/doctl-cli/ \
    && tar -xzf /opt/doctl-cli.tar.gz -C /opt/doctl-cli \
    && ln -s /opt/doctl-cli/doctl /usr/bin/doctl \
    && rm -f /opt/doctl-cli.tar.gz

USER jenkins

COPY plugins.txt $JENKINS_DIR/plugins.txt
RUN /usr/local/bin/install-plugins.sh < $JENKINS_DIR/plugins.txt

COPY init.groovy.d $JENKINS_DIR/init.groovy.d/
