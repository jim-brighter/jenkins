import hudson.PluginWrapper
import jenkins.model.Jenkins

def pluginList=Jenkins.getInstance().getPluginManager().getPlugins().collect {
        "${it.shortName}"
}.sort()
pluginList.each { println it }
