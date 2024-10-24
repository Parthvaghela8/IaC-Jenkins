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
    agent any
    stages {
        stage('Preparing') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'echo Preparing'
                    } else {
                        bat 'echo Preparing'
                    }
                }
            }
        }
        stage('Git Pulling') {
            steps {
                git branch: 'main', url: 'https://github.com/Parthvaghela8/IaC-Jenkins.git'
            }
        }
        stage('Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        if (isUnix()) {
                            sh 'terraform init'
                        } else {
                            bat 'terraform init'
                        }
                    }
                }
            }
        }
        stage('Validate') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        if (isUnix()) {
                            sh 'terraform validate'
                        } else {
                            bat 'terraform validate'
                        }
                    }
                }
            }
        }
        stage('Action') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        if (params.Terraform_Action == 'plan') {
                            if (isUnix()) {
                                sh "terraform plan -var-file=${params.Environment}.tfvars"
                            } else {
                                bat "terraform plan -var-file=${params.Environment}.tfvars"
                            }
                        } else if (params.Terraform_Action == 'apply') {
                            if (isUnix()) {
                                sh "terraform apply -var-file=${params.Environment}.tfvars -auto-approve"
                            } else {
                                bat "terraform apply -var-file=${params.Environment}.tfvars -auto-approve"
                            }
                        } else if (params.Terraform_Action == 'destroy') {
                            if (isUnix()) {
                                sh "terraform destroy -var-file=${params.Environment}.tfvars -auto-approve"
                            } else {
                                bat "terraform destroy -var-file=${params.Environment}.tfvars -auto-approve"
                            }
                        } else {
                            error "Invalid value for Terraform_Action: ${params.Terraform_Action}"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            // Send email on successful build
            mail to: env.COMMITTER_EMAIL, // Ensure a comma is present here
                 subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) Success",
                 body: "Good job! The build was successful. Check it out at ${env.BUILD_URL}"
        }
        failure {
            // Send email on failure
            mail to: env.COMMITTER_EMAIL, // Ensure a comma is present here
                 subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) Failed",
                 body: "The build failed due to your recent change. Check it out at ${env.BUILD_URL}"
        }
        unstable {
            // Send email on unstable builds
            mail to: env.COMMITTER_EMAIL, // Ensure a comma is present here
                 subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) Unstable",
                 body: "The build is unstable. Check it out at ${env.BUILD_URL}"
        }
    }
}
