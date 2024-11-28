properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment',
            description: 'The environment for Terraform operations'
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
                    }.flatten().find { it }  // Get the first email from the change set

                    env.COMMITTER_EMAIL = committerEmail ?: 'default@example.com'
                    echo "Retrieved Committer Email: ${env.COMMITTER_EMAIL}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    echo "Initializing Terraform..."
                    sh 'terraform init'  // Terraform init will run on EC2 agent
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    echo "Validating Terraform configuration..."
                    sh 'terraform validate'  // Terraform validate will run on EC2 agent
                }
            }
        }

        stage('Terraform Action') {
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
                        echo "Executing Terraform command: ${actionCmd}"
                        sh actionCmd  // Run selected Terraform action on EC2 agent
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Send an email notification regardless of the build result
                if (env.COMMITTER_EMAIL && env.COMMITTER_EMAIL != 'default@example.com') {
                    sendEmail(env.COMMITTER_EMAIL, env.JOB_NAME, env.BUILD_NUMBER, currentBuild.result)
                }
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
