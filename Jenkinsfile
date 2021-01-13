def REPO_URL = "https://github.com/jim-brighter/jenkins.git"

def isPr() {
    return env.BRANCH_NAME.startsWith("PR-")
}

def isPushToMaster() {
    return env.BRANCH_NAME == "master"
}

def ERROR = "error"
def FAILURE = "failure"
def PENDING = "pending"
def SUCCESS = "success"

def GIT_COMMIT

def updateGithubStatus(stage, state, sha) {
    withCredentials([
        usernamePassword(credentialsId: 'git-login', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')
    ]) {
        def branch = isPr() ? env.CHANGE_BRANCH : env.BRANCH_NAME
        sh """
            curl --output /dev/null --silent --fail https://api.github.com/repos/jim-brighter/jenkins/statuses/${sha} \
                -u ${GIT_USERNAME}:${GIT_PASSWORD} \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Content-Type: application/json" \
                -X POST \
                -d '{
                    "state": "${state}",
                    "target_url": "http://jimsjenkins.xyz/blue/organizations/jenkins/Jenkins/detail/${env.BRANCH_NAME}/${env.BUILD_NUMBER}/pipeline/",
                    "description": "${stage} - ${state}",
                    "context": "continuous-integration/jenkins/${stage}"
                }'
        """
    }
}

node {

    properties([[$class: 'JiraProjectProperty'], buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')),
                [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false]])

    deleteDir()

    stage("INIT") {
        gitOutput = git(
            url: "${REPO_URL}",
            credentialsId: 'git-login',
            branch: isPr() ? env.CHANGE_BRANCH : env.BRANCH_NAME
        )

        GIT_COMMIT = gitOutput.GIT_COMMIT

        updateGithubStatus(STAGE_NAME, PENDING, GIT_COMMIT)

        sh "chmod +x ./pipeline/*.sh"

        updateGithubStatus(STAGE_NAME, SUCCESS, GIT_COMMIT)
    }

    if (isPr() || isPushToMaster()) {
        stage("PULL BASE IMAGES") {
            updateGithubStatus(STAGE_NAME, PENDING, GIT_COMMIT)
            sh label: "Pull Base Images", script: "./pipeline/pull-base-images.sh"
            updateGithubStatus(STAGE_NAME, SUCCESS, GIT_COMMIT)
        }
    }

    if (isPr() || isPushToMaster()) {
        stage("BUILD JENKINS") {
            updateGithubStatus(STAGE_NAME, PENDING, GIT_COMMIT)
            sh label: "Build Jenkins Docker Image", script: "./pipeline/build-jenkins.sh"
            sh label: "Build Nginx Docker Image", script: "./pipeline/build-nginx.sh"
            updateGithubStatus(STAGE_NAME, SUCCESS, GIT_COMMIT)
        }
    }

    if (isPr() || isPushToMaster()) {
        stage("PUSH DOCKER") {
            updateGithubStatus(STAGE_NAME, PENDING, GIT_COMMIT)
            withCredentials([
                usernamePassword(credentialsId: "docker-login", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')
            ]) {
                sh label: "Push Docker Image", script: "./pipeline/push-docker.sh"
            }
            updateGithubStatus(STAGE_NAME, SUCCESS, GIT_COMMIT)
        }
    }

    if (isPushToMaster()) {
        stage("TAG") {
            updateGithubStatus(STAGE_NAME, PENDING, GIT_COMMIT)
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
            updateGithubStatus(STAGE_NAME, SUCCESS, GIT_COMMIT)
        }
    }
}
