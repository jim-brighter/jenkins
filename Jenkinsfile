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
        sh label "Pull Base Images"
            script """
                docker pull jenkins/jenkins:latest
            """
    }

    stage("BUILD JENKINS") {
        sh label "Build Jenkins Docker Image"
            script """
                docker build -t jimbrighter/jenkins:latest -f Dockerfile .
            """
    }

    stage("PUSH DOCKER") {
        withCredentials([
            usernamePassword(credentialsId: "docker-login", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')
        ]) {
            sh label "Push Docker Image"
                script """
                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                    docker push jimbrighter/jenkins:latest
                """
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
            sh label "Push Git tag and Merge to Master"
                script """
                    git remote set-url origin https://github.com/jim-brighter/jenkins.git
                    git config user.name "${GIT_NAME}"
                    git config user.email ${GIT_EMAIL}
                    git tag -a ${tag} -m "New Tag ${tag}"
                    git push ${origin} ${tag}

                    if [ "${GIT_BRANCH}" = "ci" ]; then
                        git checkout -- .
                        git checkout master
                        git merge ${GIT_BRANCH}
                        git push ${origin} master
                    else
                        exit 0
                    fi
                """
        }
    }
}