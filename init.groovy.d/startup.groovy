import jenkins.model.*
import hudson.model.*
import hudson.security.*
import java.util.logging.Logger
import java.util.List
import java.util.ArrayList
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*
import org.jenkinsci.plugins.plaincredentials.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import java.nio.file.Files
import net.sf.json.JSONObject
import hudson.util.Secret
import org.jenkinsci.plugins.plaincredentials.impl.*

Logger.global.info("Running startup script for Jim's Jenkins")

configureSecurity()
createCredentials()

Jenkins.instance.setNumExecutors(2)
Jenkins.instance.save()

Logger.global.info("Finished startup script")

private void configureSecurity() {
    def JENKINS_ADMIN_PW = System.getenv("JENKINS_ADMIN_PW")

    def securityRealm = new HudsonPrivateSecurityRealm(false)
    securityRealm.createAccount('admin', JENKINS_ADMIN_PW)
    Jenkins.instance.setSecurityRealm(securityRealm);

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)
    Jenkins.instance.setAuthorizationStrategy(strategy)
}

private void createCredentials() {
    def GIT_USERNAME = System.getenv("GIT_USERNAME")
    def GIT_PASSWORD = System.getenv("GIT_PASSWORD")
    def GIT_NAME = System.getenv("GIT_NAME")
    def GIT_EMAIL = System.getenv("GIT_EMAIL")

    def DOCKER_USERNAME = System.getenv("DOCKER_USERNAME")
    def DOCKER_PASSWORD = System.getenv("DOCKER_PASSWORD")

    def DO_TOKEN = System.getenv("DO_TOKEN")

    def NPM_TOKEN = System.getenv("NPM_TOKEN")

    Credentials githubLogin = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "git-login",
        "description:git-login",
        "${GIT_USERNAME}",
        "${GIT_PASSWORD}"
    )

    Credentials gitName = new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "git-name",
        "description:git-name",
        Secret.fromString("${GIT_NAME}")
    )

    Credentials gitEmail = new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "git-email",
        "description:git-email",
        Secret.fromString("${GIT_EMAIL}")
    )

    Credentials dockerLogin = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "docker-login",
        "description:docker-login",
        "${DOCKER_USERNAME}",
        "${DOCKER_PASSWORD}"
    )

    Credentials doToken = new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "do-token",
        "description:do-token",
        Secret.fromString("${DO_TOKEN}")
    )

    Credentials npmToken = new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "npm-token",
        "description:npm-token",
        Secret.fromString("${NPM_TOKEN}")
    )

    def credentials_store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
    credentials_store.addCredentials(Domain.global(), githubLogin)
    credentials_store.addCredentials(Domain.global(), gitName)
    credentials_store.addCredentials(Domain.global(), gitEmail)
    credentials_store.addCredentials(Domain.global(), dockerLogin)
    credentials_store.addCredentials(Domain.global(), doToken)
    credentials_store.addCredentials(Domain.global(), npmToken)
}
