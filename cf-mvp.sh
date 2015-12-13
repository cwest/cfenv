#!/usr/bin/env bash
set -x

#   ____ _                 _ _____                     _              __  ____     ______  
#  / ___| | ___  _   _  __| |  ___|__  _   _ _ __   __| |_ __ _   _  |  \/  \ \   / /  _ \ 
# | |   | |/ _ \| | | |/ _` | |_ / _ \| | | | '_ \ / _` | '__| | | | | |\/| |\ \ / /| |_) |
# | |___| | (_) | |_| | (_| |  _| (_) | |_| | | | | (_| | |  | |_| | | |  | | \ V / |  __/ 
#  \____|_|\___/ \__,_|\__,_|_|  \___/ \__,_|_| |_|\__,_|_|   \__, | |_|  |_|  \_/  |_|    
#                                                             |___/                        

# Prerequisites and Assumptions
#
# 1. Tested on a mac with up-to-date operating system and XCode installed.
# 2. Modern vagrant and VitualBox installed.
# 3. git installed.
# 4. A modern ruby installed (via rbenv, rvm, or similar).

WORKSPACE=$(mktemp -d $HOME/cf-workspace-XXXX)
STEMCELL_VERSION=2776
REDIS_VERSION=424

sudo -v # cache sudo for long enough (I hope)

cd $WORKSPACE
mkdir -p bin && cd $WORKSPACE/bin
curl -L -o spiff.zip "https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_darwin_amd64.zip"
unzip spiff.zip && rm -f spiff.zip
curl -L "https://cli.run.pivotal.io/stable?release=macosx64-binary&source=github" | tar -zx
PATH=$WORKSPACE/bin:$PATH

cd $WORKSPACE
git clone https://github.com/cloudfoundry/bosh-lite
git clone https://github.com/cloudfoundry/cf-release
git clone https://github.com/cloudfoundry-incubator/diego-release
git clone https://github.com/pivotal-cf/cf-redis-release.git

# BOSH and Cloud Foundry

cd $WORKSPACE/bosh-lite
vagrant box update
vagrant up
bin/add-route # will require sudo

gem install bosh_cli bosh_cli_plugin_micro --no-ri --no-rdoc
sleep 10
bosh target 192.168.50.4 lite
sleep 10
bosh target 192.168.50.4 lite
sleep 10
bosh target 192.168.50.4 lite

bosh upload stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=$STEMCELL_VERSION"

./bin/provision_cf

# Diego and Docker Support

cd $WORKSPACE/diego-release
git checkout master
./scripts/update
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release
./scripts/generate-bosh-lite-manifests
bosh deployment bosh-lite/deployments/diego.yml
bosh create release --name diego --force
bosh -n upload release
bosh -n deploy

cf login -a api.bosh-lite.com -u admin -p admin --skip-ssl-validation
cf enable-feature-flag diego_docker

# Redis and Redis Service Broker

cd $WORKSPACE/cf-redis-release
perl -pe 's/bundle\s+exec\s+//' manifests/cf-redis-lite.yml > cf-redis.yml
bosh deployment cf-redis.yml
bosh -n upload release releases/cf-redis/cf-redis-$REDIS_VERSION.yml
bosh -n deploy
bosh run errand broker-registrar

# Create org and space

cf create-org pivotal
cf target -o pivotal
cf create-space demo
cf target -s demo

