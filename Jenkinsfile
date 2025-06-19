pipeline {
    agent {
        label 'nodus-bizarus'
    }
    
    parameters {
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Exécuter les tests unitaires'
        )
        booleanParam(
            name: 'KEEP_ARTIFACTS',
            defaultValue: true,
            description: 'Conserver les artefacts de build'
        )
    }
    
    environment {
        PROJECT_NAME = 'calculator-app'
        BUILD_DIR = 'build'
        CC = 'gcc'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Clonage du repository..."
                checkout scm
                
                // Alternative si vous voulez spécifier explicitement le repo :
                // git url: 'https://github.com/VOTRE_USERNAME/VOTRE_REPO.git', 
                //     branch: 'main'
                
                echo "Code récupéré avec succès"
            }
        }
        
        stage('🔍 Environment Check') {
            steps {
                echo "🔧 Vérification de l'environnement..."
                sh '''
                    echo "Système: $(uname -a)"
                    echo "Compilateur: $(gcc --version | head -1)"
                    echo "Make: $(make --version | head -1)"
                    echo "Workspace: $PWD"
                    echo "Paramètres:"
                    echo "  - RUN_TESTS: ${RUN_TESTS}"
                    echo "  - KEEP_ARTIFACTS: ${KEEP_ARTIFACTS}"
                '''
            }
        }
        
        stage('Clean') {
            steps {
                echo "Nettoyage des builds précédents..."
                sh '''
                    if [ -d "build" ]; then
                        rm -rf build
                        echo "Dossier build nettoyé"
                    else
                        echo "Aucun dossier build à nettoyer"
                    fi
                '''
            }
        }
        
        stage('Tests') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                echo "Compilation et exécution des tests..."
                sh '''
                    echo "Compilation des tests..."
                    make test
                '''
            }
            post {
                always {
                    script {
                        if (fileExists('build/test_calculator')) {
                            echo "Tests compilés avec succès"
                        } else {
                            error "Échec de la compilation des tests"
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                echo "Compilation de l'application..."
                sh '''
                    echo "Début de la compilation..."
                    make all
                    
                    echo "Vérification du binaire..."
                    if [ -f "build/calculator" ]; then
                        echo "Binaire créé avec succès"
                        ls -la build/calculator
                        file build/calculator
                    else
                        echo "Échec de la création du binaire"
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Validation') {
            steps {
                echo "Test d'exécution du binaire..."
                sh '''
                    echo "Test d'exécution..."
                    ./build/calculator > execution_output.txt
                    
                    echo "Sortie du programme:"
                    cat execution_output.txt
                    
                    echo "Le programme s'exécute correctement"
                '''
            }
        }
        
        stage('Package') {
            steps {
                echo "Préparation des artefacts..."
                sh '''
                    # Création d'un package avec tous les fichiers nécessaires
                    mkdir -p package
                    cp build/calculator package/
                    cp execution_output.txt package/
                    
                    # Création d'un fichier de version
                    echo "Build: #${BUILD_NUMBER}" > package/build_info.txt
                    echo "Date: $(date)" >> package/build_info.txt
                    echo "Git Commit: ${GIT_COMMIT:-'N/A'}" >> package/build_info.txt
                    
                    echo "Contenu du package:"
                    ls -la package/
                '''
            }
        }
    }
    
    post {
        always {
            echo "🔍 Nettoyage et archivage..."
            
            script {
                if (params.KEEP_ARTIFACTS && fileExists('build/calculator')) {
                    archiveArtifacts artifacts: 'build/calculator,package/*,execution_output.txt', 
                                   fingerprint: true,
                                   allowEmptyArchive: true
                    echo "Artefacts archivés"
                } else if (!params.KEEP_ARTIFACTS) {
                    echo "Archivage des artefacts désactivé par paramètre"
                } else {
                    echo "Aucun artefact à archiver"
                }
            }
        }
        
        success {
            echo '''
            ================================
               BUILD RÉUSSI !
            ================================
              Code cloné
              Tests passés
              Compilation réussie  
              Binaire créé
              Package prêt
            ================================
            '''
            
            // Notification par email (optionnel)
            emailext (
                subject: "Build Success - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                Build terminé avec succès !
                
                Projet: ${PROJECT_NAME}
                Build: #${BUILD_NUMBER}
                Durée: ${currentBuild.durationString}
                
                Artefacts disponibles:
                - Binaire: build/calculator
                - Logs: execution_output.txt
                
                Console: ${BUILD_URL}console
                """,
                to: 'dev-team@company.com'
            )
        }
        
        failure {
            echo '''
            ================================
               BUILD ÉCHOUÉ !
            ================================
            '''
            
            emailext (
                subject: "Build Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                Le build a échoué !
                
                Projet: ${PROJECT_NAME}
                Build: #${BUILD_NUMBER}
                
                Consultez les logs: ${BUILD_URL}console
                """,
                to: 'dev-team@company.com'
            )
        }
        
        unstable {
            echo "Build instable - vérifiez les tests"
        }
    }
}
