#!/bin/sh
#
# Deploy service to k8s. This script is expected to be called
# from build pipeline having kubectl credentials setup properly.
#
# Command line arguments:
#   mode   qa or staging
#   ns     Namespace to deploy to
#   commit Version identifier
#   image1 Phantomjs image name
#   image2 Nginx image name

if [ $# -ne 5 ]; then
    echo "Expecting 5 arguments" >&2; exit 1
fi

KUBECTL=kubectl
DEPLOYMENT=report2chart

MODE=$1
NS=$2
COMMIT=$3
PHANTOMJS=$4
NGINX=$5

# In "qa" mode we just create the namespace and the required objects
# in its own isolated namespace.
mode_qa()
{
    create_ns
    create_service
}

# For "staging" mode we update the deployment if its already initialized.
# If not we initialize the staging namespace and create the objects.
mode_staging()
{
    # Create namespace if its not there 
    $KUBECTL describe namespace $NS
    if [ $? -ne 0 ]; then
        create_ns
    fi

    # Create objects if deployment not found
    $KUBECTL --namespace $NS describe deployment $DEPLOYMENT
    if [ $? -ne 0 ]; then
        create_service
        expose_service
    else
        update_service
    fi
}

create_ns()
{
    $KUBECTL create namespace $NS
}

create_service()
{
    cat k8s/pipeline/report2chart-service.yaml \
        | sed -e "s~%%COMMIT%%~$COMMIT~g" \
        | $KUBECTL --namespace $NS create -f -

    cat k8s/pipeline/report2chart-deployment.yaml \
        | sed -e "s~%%COMMIT%%~$COMMIT~g" \
        | sed -e "s~%%IMAGE_PHANTOMJS%%~$PHANTOMJS~g" \
        | sed -e "s~%%IMAGE_NGINX%%~$NGINX~g" \
        | $KUBECTL --namespace $NS create -f -
}

expose_service()
{
    # TODO: handle ingress for staging
    echo "Exposing service through ingres"
}

update_service()
{
    $KUBECTL --namespace $NS set image deployment report2chart phantomjs=$PHANTOMJS nginx=$NGINX
}

mode_$MODE
$KUBECTL --namespace $NS rollout status deployment $DEPLOYMENT

