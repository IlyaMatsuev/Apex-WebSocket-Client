#!/bin/sh

# This script pushes the last ws-dispatcher docker image to the heroku app by provided name
# Example: sh ./scripts/heroku-update.sh my-own-ws-dispatcher

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

app_name=$1

if [[ -z "$app_name" ]]
then
	echo "${red}Specify the heroku app name as the first parameter${reset}"
	exit 1
fi

echo
echo "${green}Please log into your heroku account${reset}"
heroku login || { exit 1; }
heroku container:login || { exit 1; }

echo
echo "${green}Pushing the image to heroku...${reset}"
docker pull ilyamatsuev/ws-dispatcher
docker tag ilyamatsuev/ws-dispatcher registry.heroku.com/${app_name}/web
docker push registry.heroku.com/${app_name}/web || { exit 1; }

echo
echo "${green}Running the container...${reset}"
heroku container:release web -a "$app_name" || { exit 1; }

echo
echo "${green}Done. You can find your app at https://${app_name}.herokuapp.com/${reset}"
