#!/bin/sh

# This script pushes the last docker image to the heroku app by provided name
# Example: sh ./scripts/heroku-update.sh my-own-ws-dispatcher

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

app_name=$1

info() {
    echo
    echo "${green}$1${reset}"
}

error() {
    echo "${red}$1${reset}"
	exit 1
}

if [[ -z "$app_name" ]]
then
	error "Specify the heroku app name as the first parameter"
fi

info "Please log into your heroku account"
heroku login || { exit 1; }
heroku container:login || { exit 1; }

info "Pushing the image to heroku..."
docker pull ilyamatsuev/ws-dispatcher
docker tag ilyamatsuev/ws-dispatcher registry.heroku.com/${app_name}/web
docker push registry.heroku.com/${app_name}/web || { exit 1; }

info "Running the container..."
heroku container:release web -a "$app_name" || { exit 1; }

info "Done. You can find your app at https://${app_name}.herokuapp.com/"