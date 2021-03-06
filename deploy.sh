#!/bin/bash
set -euo pipefail

export KUBE_NAMESPACE=${ENVIRONMENT:-$DRONE_DEPLOY_TO}
export KUBE_TOKEN=${KUBE_TOKEN}
export VERSION=${VERSION}

export DOMAIN="cs"
if [ "${KUBE_NAMESPACE%-*}" == "wcs" ]; then
    export DOMAIN="wcs"
fi

export KUBE_SERVER=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk
export KC_REALM=https://sso-dev.notprod.homeoffice.gov.uk/auth/realms/hocs-notprod
export UPTIME_PERIOD="Mon-Fri 08:00-18:00 Europe/London"
export KUBE_CERTIFICATE_AUTHORITY="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"

export SUBNAMESPACE="${KUBE_NAMESPACE#*-}" # e.g. dev, qa
export INTERNAL_DOMAIN="camunda-${SUBNAMESPACE}.internal.${DOMAIN}-notprod.homeoffice.gov.uk"

echo
echo "Deploying hocs-camunda-tools ${VERSION} to ${KUBE_NAMESPACE}"
echo "Keycloak realm: ${KC_REALM}"
echo "Internal domain: ${INTERNAL_DOMAIN:-nil}"
echo

cd kd || exit 1

kd --timeout 10m \
    -f hocs-camunda-tools-networkpolicy.yaml \
    -f ingress-internal.yaml \
    -f deployment.yaml \
    -f service.yaml

