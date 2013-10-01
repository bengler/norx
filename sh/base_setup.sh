#!/bin/bash

GITHUB_ACCESS_TOKEN="a09e2e7b5488f777a79b82edd506e61ccdfcbe43"

## Set locale first, or Postgresql will get in trouble later on regarding UTF8-encoded databases.
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

if [ ! -f '/home/norx/.done_packages' ]; then

	echo  "Installing needed packages with apt and pip"

	apt-get update

	apt-get -y install build-essential python-software-properties

	# Add some repositories
	apt-add-repository -y ppa:sharpie/for-science
	apt-add-repository -y  ppa:sharpie/postgis-nightly
	add-apt-repository -y ppa:mapnik/v2.1.0
	add-apt-repository -y ppa:chris-lea/node.js

	# Update package list for new repos.
	apt-get update

	## Install postgreqsql database
	apt-get -y install postgresql-9.1
	## Install PostGIS 2.1
	apt-get -y install postgresql-9.1-postgis

	## Install gdal
	apt-get -y install libgdal1-1.7.0 libgdal1-dev gdal-bin

	# Install mapnik
	sudo apt-get -y install libmapnik mapnik-utils python-mapnik libmapnik-dev

	## Install some tools needed to install services
	apt-get -y install git subversion unzip zerofree

	## Install node
	apt-get -y install nodejs

	# Install needed Python packages
	apt-get install -y libboost-python-dev python-pip python-dev

	# Install python modules
	pip install pillow TileStache pyproj


	echo  "Installing Elastic Search server with JDBC-bindings for Postgres"

	apt-get install -y openjdk-7-jre-headless
	wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb -O /tmp/elasticsearch-0.90.3.deb
	dpkg -i /tmp/elasticsearch-0.90.3.deb
	cd /usr/share/elasticsearch/bin
	./plugin -url http://bit.ly/19iNdvZ -install river-jdbc
	cd ..
	cd plugins/river-jdbc
	wget http://jdbc.postgresql.org/download/postgresql-9.1-903.jdbc4.jar

	sudo -u norx touch '/home/norx/.done_packages'
fi

echo  "Setting up GitHub user to fetch additional code"
# Git setup
git config --global user.name "Tilde Nielsen" # Bengler's test user
git config --global user.email tildeniels1@gmail.com


if [ ! -f '/home/norx/.done_dataseed' ]; then
	echo  "Seeding map data. This will take a very long time!"
	echo "    * Generating and activating humongous!! (30 GB) swapfile needed to parse BIG GeoJSON files. Some of these JSON files are as big as 12 GB!"

	# Create swapfile of 25GB with block size 1MB
	dd if=/dev/zero of=/swapfile bs=1024 count=31457280

	# Set up the swap file
	mkswap /swapfile

	# Enable swap file immediately
	swapon /swapfile

	# # Prepare to cook map data
	# echo "    * Fetching seed code from GitHub"

	# cd /home/norx
	# sudo -u norx mkdir data

	# sudo -u norx git clone "https://$GITHUB_ACCESS_TOKEN@github.com/bengler/norx_data" data

	# cd data

	# echo "    * Starting seed. Please be patient...this is going to take a long time!"

	# sudo -u norx ./seed.sh norx norx bengler

	# echo "    * Deactivating and removing humongous swap file"
	# swapoff /swapfile
	# rm -rf /swapfile
	# if [  -f '/home/norx/data' ]; then
	# 	sudo -u norx touch '/home/norx/.done_dataseed'
	# 	echo "   * Seed done!"
	# fi
fi


if [ ! -f '/home/norx/.done_postgres' ]; then
	echo  "Setting up database"
	# Postgres/PostGIS setup

	echo  "    * Creating PostGIS template"
	## Create PostGIS template
	sudo -u postgres createdb -E UTF8 template_postgis2
	sudo -u postgres createlang -d template_postgis2 plpgsql
	sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis2'"
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/postgis.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/spatial_ref_sys.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/rtpostgis.sql
	sudo -u postgres psql -d template_postgis2 -f /usr/share/postgresql/9.1/contrib/postgis-2.1/legacy.sql
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geometry_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON geography_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis2 -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

	echo  "    * Creating Postgres user 'norx' with password 'bengler'"
	sudo -u postgres psql -c "CREATE ROLE norx LOGIN INHERIT CREATEDB;"
	sudo -u postgres psql -c "ALTER USER norx WITH PASSWORD 'bengler';"

	echo  "    * Creating database 'norx'"
	sudo -u norx createdb -O norx -E UTF8 -T template_postgis2 norx

	sudo -u norx touch '/home/norx/.done_postgres'

fi

# if [ ! -f '/home/norx/.done_services' ]; then

# 	echo  "Setting up GitHub user to fetch additional code"
# 	# Git setup
# 	git config --global user.name "Tilde Nielsen" # Bengler's test user
# 	git config --global user.email tildeniels1@gmail.com

# 	echo  "Setting up map services"
# 	# Set up services that we need running
# 	cd /home/norx
# 	sudo -u norx mkdir services
# 	echo  "    * Fetching services-repository from GitHub"
# 	sudo -u norx git clone "https://$GITHUB_ACCESS_TOKEN@github.com/bengler/norx_services" services
# 	cd /home/norx/services
# 	sudo -u norx ./bootstrap.sh
# 	if [ -f '/home/norx/services' ]; then
# 		sudo -u norx touch '/home/norx/.done_services'
# 		echo "   * Services done!"
# 	fi
# fi
