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
                script {
                    echo "Running on node: ${env.NODE_NAME}"
                }
            }
        }
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Get Committer Email') {
            steps {
                script {
                    env.COMMITTER_EMAIL = sh(script: "git log -1 --pretty=format:'%ae'", returnStdout: true).trim()
                    echo "Retrieved Committer Email: ${env.COMMITTER_EMAIL}"
                }
            }
        }
        stage('Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    sh 'terraform init'
                }
            }
        }
        stage('Validate') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    sh 'terraform validate'
                }
            }
        }
        stage('Action') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        def actionCmd = ""
                        switch (params.Terraform_Action) {
                            case 'plan':
                                actionCmd = "terraform plan -var-file=${params.Environment}.tfvars"
                                break
                            case 'apply':
                                actionCmd = "terraform apply -var-file=${params.Environment}.tfvars -auto-approve"
                                break
                            case 'destroy':
                                actionCmd = "terraform destroy -var-file=${params.Environment}.tfvars -auto-approve"
                                break
                            default:
                                error "Invalid value for Terraform_Action: ${params.Terraform_Action}"
                        }
                        sh actionCmd
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sendEmail(env.COMMITTER_EMAIL ?: 'default@example.com', env.JOB_NAME, env.BUILD_NUMBER, currentBuild.result)
            }
        }
    }
}

// Function to send email
def sendEmail(String recipient, String jobName, String buildNumber, String buildResult) {
    def subject = "Job '${jobName}' (${buildNumber}) ${buildResult ?: 'Unstable'}"
    def body = generateEmailBody(jobName, buildNumber, buildResult)

    mail to: recipient, subject: subject, body: body
}

// Function to generate email body based on a template
def generateEmailBody(String jobName, String buildNumber, String buildResult) {
    def template = """
    Hello,

    This is a notification regarding your Jenkins job:

    Job Name: ${jobName}
    Build Number: ${buildNumber}
    Build Result: ${buildResult ?: 'Unstable'}

    You can view the job details at: ${env.BUILD_URL}

    Regards,
    Jenkins
    """
    return template.stripIndent()
}
