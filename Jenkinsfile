properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment',
            description: 'The environment for Terraform operations'
        ),
        string(
            name: 'committer_email',
            defaultValue: '',
            description: 'Email of the committer'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'],
            name: 'Terraform_Action',
            description: 'Select the Terraform action to perform'
        )
    ])
])

pipeline {
    agent { label 'ec2' }  // The entire pipeline will run on the EC2 agent

    stages {

        stage('Track Node') {
            steps {
                script {
                    echo "Running on node: ${env.NODE_NAME}"
                }
            }
        }
        stage('Get Committer Email') {
            steps {
               script {
                    def committerEmail = currentBuild.changeSets.collect { changeSet ->
                        changeSet.items.collect { it.authorEmail }
                    }.flatten().find { it }  // Gets the first email

                    env.COMMITTER_EMAIL = committerEmail ?: 'default@example.com'
                    echo "Retrieved Committer Email: ${env.COMMITTER_EMAIL}"
                    echo "Email to send notification: ${params.committer_email}"
                }
            }
        }
        stage('Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    sh 'terraform init'  // Terraform will run on EC2 agent
                }
            }
        }
        stage('Validate') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    sh 'terraform validate'  // Terraform validate will run on EC2 agent
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
                        sh actionCmd  // Terraform action will run on EC2 agent
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
