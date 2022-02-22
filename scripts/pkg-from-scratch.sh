red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
default_scratch_duration=30

devhub_alias=$1
scratch_alias=$2
days=${3:-$default_scratch_duration}

if [[ -z "$devhub_alias" ]]
then
	echo "${red}Specify a dev hub org alias as the first parameter${reset}"
	exit 1
fi

if [[ -z "$scratch_alias" ]]
then
	echo "${red}Specify a scratch org alias as the second parameter${reset}"
	exit 1
fi

echo
echo "${green}Please login to the devhub${reset}"
sfdx force:auth:web:login -a "$devhub_alias" || { exit 1; }

echo
echo "${green}Creating scratch...${reset}"
sfdx force:org:create -f ./sfdx-config/project-scratch-def.json -v "$devhub_alias" -a "$scratch_alias" -d "$days" || { exit 1; }

echo
echo "${green}Deploying to ${scratch_alias}...${reset}"
sfdx force:source:deploy -u "$scratch_alias" -p ./src/main || { exit 1; }
sfdx force:apex:execute -u "$scratch_alias" -f ./scripts/apex/DeployDefaultWSSettings.apex --json

echo
echo "${green}Assigning permissions...${reset}"
sfdx force:user:permset:assign -n ApexWSClientUser -u "$scratch_alias"

echo
echo "${green}Deployment has been finished."
echo "Open the org with 'sfdx force:org:open -u ${scratch_alias}'${reset}"
