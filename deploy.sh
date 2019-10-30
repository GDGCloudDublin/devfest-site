#!/bin/bash

#   
#   Created by Sergio Fraile on 11/31/19.
#

PROD_SERVICE_ACCOUNT="serviceAccount_production.json"
DEV_SERVICE_ACCOUNT="serviceAccount_develop.json"

project_id=""
production=0
deploy_database=0
deploy_webpage=0

function printLinesMargin() {
  for i in {1..3}
  do
    echo "\n"
  done
}

function displayHelp() {
  printLinesMargin
  echo "\n\nUsage: sh ./deploy.sh [arguments] \n"
  echo "Global options:"
  echo " -h, --help          Print this usage information."
  echo " -p --production     Deploy set to production."
  echo " -d --development    Deploy set to development."
  echo " -db, --database     Deploys the database."
  echo " -wp, --webpage     Deploys the webpage."
  echo "\n"
  echo "Usage example:"
  echo "sh ./deploy.sh -p -db -wp"
  printLinesMargin
}

function checkServiceAccountFileExists() {
  echo $1
  if [ -f ./$1 ];
  then
    echo "\n\nService account file found."
  else
    echo "WARNING: No service account file was found."
    exit 1
  fi
}

while [ $# -gt 0 ]; do
  case $1 in
    -p | --production )
      production=1
      project_id="gdgcloud-dublin-devfest"
      shift
      ;;
    -d | --development )
      production=0
      project_id="dublin-devfest"
      shift
      ;;
    -db | --database )
      deploy_database=1
      shift
      ;;
    -wp | --webpage )
      deploy_webpage=1
      shift
      ;;
    -h | --help )
      displayHelp
      exit 1
      ;;
    *)
      echo "\n\nWrong usage, not recognized $1 command."
      displayHelp
      exit 1
    esac
done

echo "\n\nSetting firebase to use $project_id"
npx firebase use $project_id

if [ "$production" == 1 ]
then
  echo "\n\nOverwriting serviceAccount with production config..."
  checkServiceAccountFileExists "$PROD_SERVICE_ACCOUNT"
  cat ./$PROD_SERVICE_ACCOUNT > ./serviceAccount.json
else
  echo "\n\nOverwriting serviceAccount with development config..."
  checkServiceAccountFileExists "$DEV_SERVICE_ACCOUNT"
  cat ./$DEV_SERVICE_ACCOUNT > ./serviceAccount.json
fi

if [ "$deploy_database" == 1 ]
then
  echo "\n\nDeploying database..."
  yarn firestore:init
  echo "\n\nDatabase deployed"
fi

if [ "$deploy_webpage" == 1 ]
then
  if [ "$production" == 1 ]
  then
    echo "\n\nBuilding website..."
    yarn build:prod
    echo "\n\nDeploying website..."
    yarn deploy:prod
    echo "\n\n\Website deployed"
  else
    echo "WARNING: Website deployment for develop is not supported. Skipping this step."
    # echo "\n\nBuilding website..."
    # yarn build
    # echo "\n\nDeploying website..."
    # yarn deploy
    # echo "\n\nWebsite deployed"
  fi              
fi

exit 0
