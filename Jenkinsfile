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
            }
        }
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Get Pusher Email') {
            steps {
                script {
                    // Set the environment variable dynamically
                    env.PUSHER_EMAIL = env.GIT_AUTHOR_EMAIL ?: 'vaghela.parthbhai.dcs24@vnsgu.ac.in'
                    echo "Pusher Email: ${env.PUSHER_EMAIL}"
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
                sendEmail(env.PUSHER_EMAIL, env.JOB_NAME, env.BUILD_NUMBER, currentBuild.result)
            }
        }
    }
}

// Function to send email using the Email Extension plugin
def sendEmail(String recipient, String jobName, String buildNumber, String buildResult) {
    def subject = "Job '${jobName}' (${buildNumber}) ${buildResult ?: 'Unstable'}"
    def body = generateEmailBody(jobName, buildNumber, buildResult)

    emailext(
        to: recipient,
        subject: subject,
        body: body,
        attachLog: true
    )
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
