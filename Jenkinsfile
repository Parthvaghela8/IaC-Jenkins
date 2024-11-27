properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'],
            name: 'Terraform_Action'
        )
    ])
])

pipeline {
    agent { label 'ec2' }

    stages {
        stage('Track Node') {
            steps {
                echo "Running on node: ${env.NODE_NAME}"
                sh '/usr/bin/git --version'
            }
        }
        stage('Git Version') {
            steps {
                sh 'git --version'
            }
        }
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Get Triggered User Email') {
            steps {
                script {
                    // Try to retrieve the commit author's email from the SCM trigger
                    def committerEmail = env.GIT_COMMITTER_EMAIL ?: env.GIT_AUTHOR_EMAIL ?: 'unknown@example.com'
                    echo "Committer Email: ${committerEmail}"
                    // Store email for later use in post action
                    currentBuild.description = "Triggered by ${committerEmail}"
                }
            }
        }
    }

    post {
        always {
            script {
                // Ensure the email recipient is correctly passed from the SCM trigger stage
                def userEmail = currentBuild.description?.replace("Triggered by ", "") ?: "default@example.com"
                sendEmail(userEmail, env.JOB_NAME, env.BUILD_NUMBER, currentBuild.result)
            }
        }
    }
}

// Function to send email using default Jenkins email notification
def sendEmail(String recipient, String jobName, String buildNumber, String buildResult) {
    def subject = "Job '${jobName}' (${buildNumber}) ${buildResult ?: 'Unstable'}"
    def body = generateEmailBody(jobName, buildNumber, buildResult)

    // Use Jenkins default mail functionality
    mail to: recipient,
         subject: subject,
         body: body
}

// Function to generate email body based on a template
def generateEmailBody(String jobName, String buildNumber, String buildResult) {
    return """
    Hello,

    This is a notification regarding your Jenkins job:

    Job Name: ${jobName}
    Build Number: ${buildNumber}
    Build Result: ${buildResult ?: 'Unstable'}

    You can view the job details at: ${env.BUILD_URL}

    Regards,
    Jenkins
    """.stripIndent()
}
