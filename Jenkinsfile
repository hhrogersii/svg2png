#!groovy

podTemplate(
    label: 'report2chart-pipeline',
    containers: [
        // Used to run concurrency tests
        containerTemplate(
            name: 'npm',
            image: 'mkenney/npm',
            ttyEnabled: true,
            command: 'cat'
        ),
        // Used to build the container image
        containerTemplate(
            name: 'docker',
            image: 'docker',
            ttyEnabled: true,
            command: 'cat'
        ),
        // Used to deploy service to k8s
        containerTemplate(
            name: 'kubectl',
            image: 'lachlanevenson/k8s-kubectl',
            ttyEnabled: true,
            command: 'cat'
        ),
    ],
    volumes: [
        // Required docker socket to be able to build container images. This will use
        // the docker service available on the k8s node directly.
        hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
    ]
) {
    node('report2chart-pipeline') {

        // Version will contain the git commit hash to be used later on
        // as an identifier for container images, k8s objects, etc.
        def version = ''

        // Checkout the code from source control and set the version identifier.
        stage('Github Checkout') {
            checkout scm
            sh "git rev-parse --short HEAD > .git/commit-id"
            version = readFile('.git/commit-id').trim()
        }

        // The container image identifiers
        def imagePhantomjs = "registry.sugarcrm.net/report2chart/phantomjs:${version}"
        def imageNginx = "registry.sugarcrm.net/report2chart/nginx:${version}"

        // Kubernetes namespaces
        def qaNs = "report2chart-${version}"
        def stagingNs = "report2chart-staging"

        // Build the service containers and publish them to the registry. We need to publish
        // them because we are going to schedule a pod later on which can end up on a
        // different node in the k8s cluster.
        // TODO: can we use built-in docker build/push from Jenkins instead of sep container ?
        stage('Baking Containers') {
            container(name:'docker') {
                sh """
                docker build -t ${imagePhantomjs} .
                docker push ${imagePhantomjs}
                docker build -t ${imageNginx} -f Dockerfile.nginx .
                docker push ${imageNginx}
                """
            }
        }

        // Deploy the service so we can run tests against it
        stage('Deploy Service') {
            container(name:'kubectl') {
                sh """
                kubectl version
                kubectl get namespace | grep report2chart
                ./k8s/pipeline/deploy.sh qa ${qaNs} ${version} ${imagePhantomjs} ${imageNginx}
                """
            }
        }

        // Run API tests
        stage('API Tests') {
            echo 'API and E2E Tests to be added'
        }

        // Branch specific logic
        switch (env.BRANCH_NAME) {

            // Deploy to staging environment and run concurrency tests
            case ["staging"]:
                lock(resource: 'report2chart-staging') {

                    stage('Deploy Staging') {
                        container(name:'kubectl') {
                            sh """
                            kubectl version
                            ./k8s/pipeline/deploy.sh staging ${stagingNs} ${version} ${imagePhantomjs} ${imageNginx}
                            """
                        }
                    }

                    stage('Concurrency Tests') {

                        // Using 1 replica
                        container(name:'kubectl') {
                            sh """
                            kubectl --namespace ${stagingNs} scale deployment report2chart --replicas=1
                            kubectl --namespace ${stagingNs} rollout status deployment report2chart
                            """
                        }
                        container(name:'npm') {
                            sh """
                            cd test/
                            sed -i "s~%%URL%%~http://report2chart.${stagingNs}/api/v1/pie~g" concurrency.js
                            npm install
                            npm test
                            """
                        }

                        // Using 4 replicas
                        container(name:'kubectl') {
                            sh """
                            kubectl --namespace ${stagingNs} scale deployment report2chart --replicas=4
                            kubectl --namespace ${stagingNs} rollout status deployment report2chart
                            """
                        }
                        container(name:'npm') {
                            sh """
                            cd test/
                            npm test
                            """
                        }

                        // We leave the 4 replicas - this needs to reflect production
                    }

                }
                break

            // Deploy to production - need to trigger on release tags as well
            // This probably means at this point to push the image to
            // the registry used by ops at this point
            case ["master"]:
                lock(resource: 'report2chart-production') {
                }
                break
        }

        // We need to cleanup all the k8s objects we have deployed. By using proper tags
        // using the version identifier this should be straightforward to cleanup.
        // TODO: this needs to run *always* regardless of failures above
        stage('Cleanup') {
            container(name:'kubectl') {
                sh """
                kubectl delete namespace ${qaNs}
                """
            }
        }
    }
}
