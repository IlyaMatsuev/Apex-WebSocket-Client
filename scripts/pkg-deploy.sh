red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

org_alias=$1

if [[ -z "$org_alias" ]]
then
	echo "${red}Specify the org alias or username as the first parameter${reset}"
	exit 1
fi

echo
echo "${green}Please login to the org${reset}"
sfdx force:auth:web:login -a "$org_alias" || { exit 1; }

echo
echo "${green}Deploying to ${org_alias}...${reset}"
sfdx force:source:deploy -u "$org_alias" -p ./src/main || { exit 1; }
sfdx force:apex:execute -u "$org_alias" -f ./scripts/apex/DeployDefaultWSSettings.apex --json

echo
echo "${green}Assigning permissions...${reset}"
sfdx force:user:permset:assign -n ApexWSClientUser -u "$scratch_alias"

echo
echo "${green}Deployment has been finished"
echo "Open the org with 'sfdx force:org:open -u ${org_alias}'${reset}"
