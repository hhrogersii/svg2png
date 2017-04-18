#!/bin/sh
#
# Generate k8s object file for pipeline
#
# Command line arguments:
#   version Version identifier
#   image1  Phantomjs image name
#   image2  Nginx image name

if [ $# -ne 3 ]; then
    echo "Expecting 2 arguments" >&2; exit 1
fi

cat k8s/pipeline/report2chart-deployment.yaml \
    | sed -e "s~%%VERSION%%~$1~g" \
    | sed -e "s~%%IMAGE_PHANTOMJS%%~$2~g" \
    | sed -e "s~%%IMAGE_NGINX%%~$3~g" \
    > report2chart-deployment.yaml
echo "*** Generated report2chart-deployment.yaml ***"
cat report2chart-deployment.yaml

cat k8s/pipeline/report2chart-service.yaml \
    | sed -e "s~%%VERSION%%~$1~g" \
    > report2chart-service.yaml
echo "*** Generated report2chart-service.yaml ***"
cat report2chart-service.yaml
