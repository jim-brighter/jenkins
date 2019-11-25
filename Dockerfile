FROM jenkins/jenkins:latest

ENV JENKINS_DIR /usr/share/jenkins/ref

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false \
                -XX:+UnlockExperimentalVMOptions \
                -XX:+UseCGroupMemoryLimitForHeap \
                -XX:MaxRAMFraction=2

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && export TERM=linux \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common python-pip nodejs build-essential postgresql-client-9.6 \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && systemctl enable docker \
    && usermod -aG docker jenkins \
    && curl -L https://github.com/digitalocean/doctl/releases/download/v1.18.0/doctl-1.18.0-linux-amd64.tar.gz -o /opt/doctl-cli.tar.gz \
    && mkdir -p /opt/doctl-cli/ \
    && tar -xzf /opt/doctl-cli.tar.gz -C /opt/doctl-cli \
    && ln -s /opt/doctl-cli/doctl /usr/bin/doctl

USER jenkins

COPY plugins.txt $JENKINS_DIR/plugins.txt
RUN /usr/local/bin/install-plugins.sh < $JENKINS_DIR/plugins.txt

COPY jobs $JENKINS_DIR/jobs/
COPY init.groovy.d $JENKINS_DIR/init.groovy.d/
