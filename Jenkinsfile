def REPO_URL = "https://github.com/jim-brighter/jenkins.git"

def isPr() {
    return env.BRANCH_NAME.startsWith("PR-")
}

def isPushToMaster() {
    return env.BRANCH_NAME == "master"
}

node {
    deleteDir()

    stage("INIT") {
        git(
            url: "${REPO_URL}",
            credentialsId: 'git-login',
            branch: isPr() ? env.CHANGE_BRANCH : env.BRANCH_NAME
        )
        sh "chmod +x ./pipeline/*.sh"
    }

    if (isPr() || isPushToMaster()) {
        stage("PULL BASE IMAGES") {
            sh label: "Pull Base Images", script: "./pipeline/pull-base-images.sh"
        }
    }

    if (isPr() || isPushToMaster()) {
        stage("BUILD JENKINS") {
            sh label: "Build Jenkins Docker Image", script: "./pipeline/build-jenkins.sh"
        }
    }

    if (isPr() || isPushToMaster()) {
        stage("PUSH DOCKER") {
            withCredentials([
                usernamePassword(credentialsId: "docker-login", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')
            ]) {
                sh label: "Push Docker Image", script: "./pipeline/push-docker.sh"
            }
        }
    }

    if (isPushToMaster()) {
        stage("TAG") {
            withCredentials([
                usernamePassword(credentialsId: "git-login", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')
            ]) {
                def tag = "jenkins-${BUILD_TIMESTAMP}-${BRANCH_NAME}"
                tag = tag.replace(" ", "_",).replace(":","-")
                def origin = "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jim-brighter/jenkins.git"

                withEnv([
                    "origin=${origin}",
                    "tag=${tag}"
                ]) {

                    sh label: "Push Git Tag", script: "./pipeline/push-git-tag.sh"
                }
            }
        }
    }
}