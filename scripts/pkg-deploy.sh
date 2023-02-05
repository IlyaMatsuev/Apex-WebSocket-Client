#!/bin/sh

# This script deploys and configures the SF source part to the organization by the provided username or alias
# Example: sh ./scripts/pkg-deploy.sh test.sandbox@test.com

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

org_alias=$1

info() {
    echo
    echo "${green}$1${reset}"
}

error() {
    echo "${red}$1${reset}"
	exit 1
}

if [[ -z "$org_alias" ]]
then
	error "Specify the org alias or username as the first parameter"
fi

info "Deploying components..."
sfdx force:source:deploy -u "$org_alias" -p ./src/main \
    || (\
        info "Please login to the org" \
        && sfdx force:auth:web:login -a "$org_alias" \
        && sfdx force:source:deploy -u "$org_alias" -p ./src/main \
    ) || { exit 1; }
sfdx force:apex:execute -u "$org_alias" -f ./scripts/apex/DeployDefaultWSSettings.apex --json

info "Assigning permissions..."
sfdx force:user:permset:assign -n ApexWSClientUser -u "$org_alias"

info "Deployment has been finished.\\nOpen the org with 'sfdx force:org:open -u $org_alias'"
