#!/bin/bash

# Define color variables
red=`tput setaf 1`
green=`tput setaf 2`
cyan=`tput setaf 6`
reset=`tput sgr0`

# Check if Python3 is installed

if command -v python3 &>/dev/null; then
    echo -e "\n${green}Python 3 is installed${reset}"
else
    echo -e "\n${green}Python 3 is not installed. Please install it to use this script.${reset}"
    exit
fi

if command -v virtualenv >/dev/null 2>&1; then
    echo -e "\n${green}virtualenv found${reset}"
else
    echo -e "\n${green}virtualenv not found, you need to install it to use this script.${reset}"
    exit
fi

if which -s psql; then
    echo -e "\n${green}Postgres is installed${reset}"
else
    echo -e "\n${green}Postgres is not installed. Please install it to use this script.${reset}"
    exit
fi

echo -e "\n${cyan}Creating 'shoppinglist-api' directory${reset}"
[ -d shoppinglist-api ] || mkdir shoppinglist-api

echo -e "\n${green}Directory created successfully${reset}"

echo -e "\n${cyan}Entering 'shoppinglist-api' directory${reset}"
cd shoppinglist-api

echo -e "\n${cyan}Creating 'sapi-venv' virtual environment${reset}"
virtualenv -p python3 sapi-venv

echo -e "\n${cyan}Activating virtual environment${reset}"
source sapi-venv/bin/activate

echo -e "\n${cyan}Cloning shoppinglist-api repo${reset}"
git clone https://github.com/Arthur236/shopping-list-api.git

echo -e "\n${cyan}Entering 'shopping-list-api' directory${reset}"
cd shopping-list-api

echo -e "\n${cyan}Installing dependancies${reset}"
pip install -r requirements.txt

echo -e "\n${cyan}Creating database as default postgres user${reset}"
psql postgres -c "CREATE DATABASE shoppinglist_api"

echo -e "\n${cyan}Creating '.env' file${reset}"
touch .env

echo -e "\n${cyan}Writing environment variables to '.env' file${reset}"
echo -e 'export FLASK_APP=run.py
export SECRET=some_random_long_text
export APP_SETTINGS=development
export DATABASE_URL=postgresql://postgres:@localhost/shoppinglist_api\n' > .env

echo -e "\n${cyan}Sourcing '.env' file${reset}"
source .env

echo -e "\n${cyan}Initializing database${reset}"
[ -d migrations ] || python manage.py db init

echo -e "\n${cyan}Migrating tables${reset}"
python manage.py db migrate
python manage.py db upgrade

echo -e "\n${cyan}Running application${reset}"
flask run
