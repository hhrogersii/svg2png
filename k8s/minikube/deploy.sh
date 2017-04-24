#!/bin/bash
#
# Deploy report2chart service to minikube for local development.
#
# The deployment happens in the report2chart namespace and needs
# to be initialized once. After that the deployment can be updated
# directly which will generate a new container and the service
# will be updated.

## TODO:
# * Check yaml/json save in editor
# * Advanced config for editor (missing ?)

# Available commands
if [ $# -ne 1 ]; then
    echo "Available commands:"
    echo "  init     Initializes the environment"
    echo "  update   Update the deployment"
    echo "  cleanup  Cleanup the deployment"
    echo "  status   Show deployment information"
    exit 1
fi

MINIKUBE=minikube
KUBECTL=kubectl
DOCKER=docker
NS=report2chart
APP=report2chart
LOG=debug.log

command_init()
{
    # Create namespace
    echo -e " * Creating namespace $NS ... \c" 
    $KUBECTL create namespace $NS &> $LOG 
    if [ $? -ne 0 ]; then
        echo "Error creating namespace $NS" >&2; exit 1
    fi
    echo "done"

    build_phantomjs
    build_nginx
    build_tools

    # Create service
    echo -e " * Create service $APP ... \c"
    $KUBECTL --namespace $NS create -f $DIR/report2chart-service.yaml &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error creating service $APP" >&2; exit 1
    fi
    echo "done"

    # Create service for tools - this is required as an init container
    # will wait for the service to become available for nginx config
    echo -e " * Create service tools ... \c"
    $KUBECTL --namespace $NS create -f $DIR/tools-service.yaml &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error creating tools service" >&2; exit 1
    fi
    echo "done"

    # Create deployment
    echo -e " * Create deployment $APP ... \c"
    cat $DIR/report2chart-deployment.yaml \
        | sed -e "s~%%IMAGE_PHANTOMJS%%~${IMAGE_PHANTOMJS}~g" \
        | sed -e "s~%%IMAGE_NGINX%%~${IMAGE_NGINX}~g" \
        | sed -e "s~%%ROOT%%~${ROOT_DIR_VM}~g" \
        | $KUBECTL --namespace $NS create -f - &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error creating deployment $APP" >&2; exit 1
    fi
    echo "done"

    tools

    echo -e " * Waiting for service to come alive ... \c"
    info_gather
    echo -e "done\n"
    info_display
}

command_update()
{
    check_deployment
    build_phantomjs

    # Update image
    echo -e " * Update deployment $APP to $IMAGE_PHANTOMJS ... \c"
    $KUBECTL --namespace $NS set image deployment $APP $APP=$IMAGE_PHANTOMJS &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error updating $APP" >&2; exit 1
    fi

    # Verify deployment
    $KUBECTL --namespace $NS rollout status deployment $APP &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error updating $APP" >&2; exit 1
    fi

    # Ensure the service is available, this will block until we are good
    info_gather_report2chart

    echo "done"
}

command_cleanup()
{
    # cleanup all objects
    echo -e " * Cleaning up namespace $NS ..\c"

    $KUBECTL --namespace $NS delete deployment $APP &> $LOG
    $KUBECTL --namespace $NS delete service $APP &> $LOG

    $KUBECTL --namespace $NS delete deployment swagger-ui &> $LOG
    $KUBECTL --namespace $NS delete service swagger-ui &> $LOG

    $KUBECTL --namespace $NS delete deployment tools &> $LOG
    $KUBECTL --namespace $NS delete service tools &> $LOG
    $KUBECTL --namespace $NS delete config tools &> $LOG

    $KUBECTL delete namespace $NS &> $LOG

    # wait until namespace is confirmed to be gone
    hasNs=1
    while [ $hasNs -eq 1 ]; do
        echo -e ".\c"
        $KUBECTL describe namespace $NS &> $LOG
        if [ $? -ne 0 ]; then
            hasNs=0
            echo " done"
        fi
        sleep 1
    done
}

command_status()
{
    check_deployment
    echo
    info_gather
    info_display
}

check_deployment()
{
    echo -e " * Checking deployment ... \c"
    $KUBECTL --namespace $NS describe deployment $APP &> $LOG
    if [ $? -ne 0 ]; then
        echo "Deployment $APP not found" >&2; exit 1
    fi
    echo "done"
}

build_phantomjs()
{
    IMAGE_PHANTOMJS="report2chart-phantomjs:${COMMIT}-${TS}"
    echo -e " * Building container image ${IMAGE_PHANTOMJS} ... \c"
    $DOCKER build -t ${IMAGE_PHANTOMJS} $DIR/../../ &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error building container image ${IMAGE_PHANTOMJS}" >&2; exit 1
    fi
    echo "done"
}

build_nginx()
{
    IMAGE_NGINX="report2chart-nginx:${COMMIT}-${TS}"
    echo -e " * Building container image ${IMAGE_NGINX} ... \c"
    $DOCKER build -t ${IMAGE_NGINX} -f $DIR/../../Dockerfile.mc_nginx $DIR/../../ &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error building container image ${IMAGE_NGINX}" >&2; exit 1
    fi
    echo "done"
}

build_tools()
{
    IMAGE_TOOLS="report2chart-tools:${COMMIT}-${TS}"
    echo -e " * Building container image ${IMAGE_TOOLS} ... \c"
    $DOCKER build -t ${IMAGE_TOOLS} -f $DIR/../../Dockerfile.mc_tools $DIR/../../ &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error building container image ${IMAGE_TOOLS}" >&2; exit 1
    fi
    echo "done"
}

info_gather()
{
    info_gather_report2chart
    info_gather_swagger_ui
    info_gather_tools
}

info_gather_report2chart()
{
    url_report2chart=$(minikube service -n $NS $APP --url 2> $LOG)
}

info_gather_swagger_ui()
{
    url_swagger_ui=$(minikube service -n $NS ui --url 2> $LOG)
}

info_gather_tools()
{
    url_tools=$(minikube service -n $NS tools --url 2> $LOG)
}

info_display()
{
    echo "----------------------------------------------------------------------"
    echo "Report2chart Service: $url_report2chart/swagger.json"
    echo "----------------------------------------------------------------------"
    echo "Swagger Editor: $url_report2chart/editor/"
    echo "Swagger UI: $url_swagger_ui/"
    echo "----------------------------------------------------------------------"
    echo "Test tools: $url_tools/test/"
    echo "----------------------------------------------------------------------"
}

tools()
{
    echo -e " * Deploying tools ... \c"

    # config
    info_gather_report2chart
    cat $DIR/tools-config.yaml \
        | sed -e "s~%%SVC%%~${url_report2chart}/api/v1~g" \
        | sed -e "s~%%SWAGGER%%~${url_report2chart}/swagger.json~g" \
        | $KUBECTL --namespace $NS create -f - &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error creating tools config" >&2; exit 1
    fi

    # deployment
    cat $DIR/tools-deployment.yaml \
        | sed -e "s~%%IMAGE_TOOLS%%~${IMAGE_TOOLS}~g" \
        | sed -e "s~%%ROOT%%~${ROOT_DIR_VM}~g" \
        | $KUBECTL --namespace $NS create -f - &> $LOG
    if [ $? -ne 0 ]; then
        echo "Error creating tools deployment" >&2; exit 1
    fi

    echo "done"
}

init()
{
    check_dir

    # Log file
    #LOG=$DIR/$LOG
    LOG=/dev/null

    # Check minikube and kubectl commands
    echo -e " * Checking minikube ... \c"
    command -v $MINIKUBE >/dev/null 2>&1 || { echo "$MINIKUBE command not found" >&2; exit 1; }

    # Minikube status
    minikube status &> /dev/null 
    if [ $? -ne 0 ]; then
        echo "Minikube is not running" >&2; exit 1
    fi
    echo "done"

    # Kubectl checks
    echo -e " * Checking kubectl ... \c"
    command -v $KUBECTL >/dev/null 2>&1 || { echo "$KUBECTL command not found" >&2; exit 1; }
    context=$($KUBECTL config current-context)
    if [ $context != "minikube" ]; then
        echo "Kubectl is not set to use 'minikube' context" >&2; exit 1
    fi

    # Build images directly against minikube
    eval $(minikube docker-env)

    # Create image id 
    COMMIT=$(git rev-parse --short HEAD 2> /dev/null)
    TS=$(date +%s)

    echo "done"
}

check_dir()
{
    # Check directory, should be /home or /Users and proper git dir
    echo -e " * Checking source directory ... \c"

    # Directory where deploy.sh lives
    DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

    # Project root directory
    ROOT_DIR="$DIR/../.."

    # Excepting "home" (linux) or "Users" (darwin) as top level directory
    currentDir=$(echo $DIR | awk 'BEGIN { FS="/" } { print $2 }')

    # echo ${OSTYPE} returns darwin15
    # echo $(uname -s) returns Darwin

    if [ "$(uname -s)" == "Darwin" ]; then
        expectedHome="Users"
    else
        expectedHome="home"
    fi

    if [ "$currentDir" != "$expectedHome" ]; then
        echo "Not using homedir location ($currentDirKubectl)" >&2; exit 1
    fi

    # The VM_DIR variable will hold the corresponding vm directory to which the home
    # folder is mounted. This is needed for any pods which mount hostPath on the k8s
    # node (vm) so it becomes possible to mount directly from the local system.

    if [ "$OSTYPE" == "darwin" ]; then
        ROOT_DIR_VM=$ROOT_DIR
    else
        ROOT_DIR_VM=$(echo $ROOT_DIR | sed -e "s~/home/~/hosthome/~")
    fi

    echo "done"
}


init
command_$1

