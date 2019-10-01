def REPO_URL = "https://github.com/jim-brighter/jenkins.git"

node {
    deleteDir()

    stage("INIT") {
        GIT_BRANCH = GIT_BRANCH.replace("origin/", "")
        git(
            url: "${REPO_URL}",
            credentialsId: 'git-login',
            branch: "${GIT_BRANCH}"
        )
        currentBuild.setDisplayName("${GIT_BRANCH}-${BUILD_NUMBER}")
        sh "chmod +x ./pipeline/*.sh"
    }

    stage("PULL BASE IMAGES") {
        sh label: "Pull Base Images", script: "./pipeline/pull-base-images.sh"
    }

    stage("BUILD JENKINS") {
        sh label: "Build Jenkins Docker Image", script: "./pipeline/build-jenkins.sh"
    }

    stage("PUSH DOCKER") {
        withCredentials([
            usernamePassword(credentialsId: "docker-login", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')
        ]) {
            sh label: "Push Docker Image", script: "./pipeline/push-docker.sh"
        }
    }

    stage("MERGE") {
        withCredentials([
            usernamePassword(credentialsId: "git-login", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME'),
            string(credentialsId: 'git-name', variable: 'GIT_NAME'),
            string(credentialsId: 'git-email', variable: 'GIT_EMAIL')
        ]) {
            def tag = "jenkins-${BUILD_TIMESTAMP}-${GIT_BRANCH}"
            tag = tag.replace(" ", "_",).replace(":","-")
            def origin = "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jim-brighter/jenkins.git"

            withEnv([
                "origin=${origin}",
                "tag=${tag}"
            ]) {

                sh label: "Push Git Tag", script: "./pipeline/push-git-tag.sh"

                if (GIT_BRANCH == "ci") {
                    sh label: "Merge to Master", script: "./pipeline/merge-to-master.sh"
                }
            }
        }
    }
}