pipeline {
    agent { label 'ec2' }

    // Define parameters for environment and Terraform action type
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

    tools {
        // Define the tool path for Git to avoid Jenkins using the master node's Git
        git 'git' // You can set the Git installation if needed or leave this empty if Git is in PATH
    }

    stages {
        // Stage to track the node the job is running on
        stage('Track Node') {
            steps {
                echo "Running on node: ${env.NODE_NAME}"
                sh 'which git'  // Verify the git path is correct on EC2
                sh 'git --version'  // Ensure Git version is installed
            }
        }

        // Stage to verify the Git version
        stage('Git Version') {
            steps {
                sh 'git --version'  // Check that Git is working correctly
            }
        }

        // Stage for SCM Checkout
        stage('SCM Checkout') {
            steps {
                checkout scm  // This will check out the code from the repository
            }
        }

        // Stage to get the email of the user who triggered the build
        stage('Get Triggered User Email') {
            steps {
                script {
                    // Get the email of the committer from the environment variables
                    def committerEmail = env.GIT_COMMITTER_EMAIL ?: env.GIT_AUTHOR_EMAIL
                    echo "Committer Email: ${committerEmail}"

                    // Use committerEmail in the email notification later
                    env.USER_EMAIL = committerEmail
                }
            }
        }

        // Terraform action stage (init, plan, apply, destroy)
        stage('Terraform Action') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        def terraformCmd = ""

                        // Switch based on the Terraform action selected in the parameters
                        switch (params.Terraform_Action) {
                            case 'plan':
                                terraformCmd = "terraform plan -var-file=${params.Environment}.tfvars"
                                break
                            case 'apply':
                                terraformCmd = "terraform apply -var-file=${params.Environment}.tfvars -auto-approve"
                                break
                            case 'destroy':
                                terraformCmd = "terraform destroy -var-file=${params.Environment}.tfvars -auto-approve"
                                break
                            default:
                                error "Invalid value for Terraform_Action: ${params.Terraform_Action}"
                        }

                        // Run the Terraform command
                        sh terraformCmd
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Ensure email is sent after the build completes
                sendEmail(env.USER_EMAIL, env.JOB_NAME, env.BUILD_NUMBER, currentBuild.result)
            }
        }
    }
}

// Function to send email using Jenkins' built-in mail functionality
def sendEmail(String recipient, String jobName, String buildNumber, String buildResult) {
    def subject = "Job '${jobName}' (${buildNumber}) ${buildResult ?: 'Unstable'}"
    def body = generateEmailBody(jobName, buildNumber, buildResult)

    // Use Jenkins default mail functionality
    mail to: recipient,
         subject: subject,
         body: body
}

// Function to generate the email body based on the build result
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
