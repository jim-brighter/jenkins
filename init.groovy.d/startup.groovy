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
    Logger.global.info("Here is where I'll setup credentials")
}