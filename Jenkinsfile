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
    }

    stage("PULL BASE IMAGES") {
        sh script: "./pipeline/pull-base-images.sh", label: "Pull Base Images"
    }

    stage("BUILD JENKINS") {
        sh script: "./pipeline/build-jenkins.sh", label: "Build Jenkins Docker Image"
    }

    stage("PUSH DOCKER") {
        withCredentials([
            usernamePassword(credentialsId: "docker-login", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')
        ]) {
            sh script: "./pipeline/push-docker.sh", label: "Push Docker Image"
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

            sh script: "./pipeline/push-git-tag.sh", label: "Push Git Tag"
            
            if (GIT_BRANCH == "ci") {
                sh script "./pipeline/merge-to-master.sh", label: "Merge to Master"
            }
        }
    }
}