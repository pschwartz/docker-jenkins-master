#!/bin/sh

if [ $# -eq 0 ]; then
    echo "USAGE: $0 <plugin_dir> <plugin file> ..."
  exit 1
fi

plugin_dir=$1
file_owner=jenkins.jenkins

mkdir -p ${plugin_dir}

installPlugin() {
  if [ -f ${plugin_dir}/${1}.hpi ] || [ -f ${plugin_dir}/${1}.jpi ]; then
    echo "Skipped: $1 (already installed)"
    return 0
  else
    echo "Installing: $1"
    curl -k -L --silent --output ${plugin_dir}/${1}.jpi  https://updates.jenkins-ci.org/latest/${1}.hpi
    touch ${plugin_dir}/${1}.jpi.pinned
    getDeps "$plugin"
    return 0
  fi
}

getDeps() {
    deps=$( unzip -p ${plugin_dir}/${1}.jpi META-INF/MANIFEST.MF | tr -d '\r' | sed -e ':a;N;$!ba;s/\n //g' | grep -e "^Plugin-Dependencies: " | awk '{ print $2 }' | tr ',' '\n' | awk -F ':' '{ print $1 }' | tr '\n' ' ' )
    for plugin in $deps; do
        installPlugin "$plugin"
    done
}

for plugin in `cat $2`
do
    installPlugin "$plugin"
done


echo "fixing permissions"

chown ${file_owner} ${plugin_dir} -R

echo "all done"
