import jenkins.model.*
import hudson.model.*
import hudson.security.*
import java.util.logging.Logger
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

    def credentials_store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
    credentials_store.addCredentials(Domain.global(), githubLogin)
    credentials_store.addCredentials(Domain.global(), gitName)
    credentials_store.addCredentials(Domain.global(), gitEmail)
}