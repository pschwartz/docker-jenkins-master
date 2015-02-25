#!/bin/bash

[ -f "$JENKINS_PERSIST/local/env" ] && . "$JENKINS_PERSIST/local/env"

if [ -v RUNLOCAL ]; then
    echo "Running from local mount..."
    if [ "$JENKINS_PERSIST/local/config.xml" -nt /config.xml ]; then
        if [ -f "$JENKINS_PERSIST/local/config.xml" ]; then
            if [ -f "/config.xml" ]; then
                mv /config.xml /config.xml.bak
            fi

            if [ -f "$JENKINS_PERSIST/config.xml" ]; then
                rm $JENKINS_PERSIST/config.xml
            fi

            cp $JENKINS_PERSIST/local/config.xml /config.xml
        fi

        if [ -f "$JENKINS_PERSIST/local/jenkins.plugins" ]; then
            if [ -d "/plugins" ]; then
                rm -rf /plugins
                mkdir /plugins
            fi

            /install_plugins.sh /plugins $JENKINS_PERSIST/local/jenkins.plugins
        fi
    fi
fi

if [ -v REVERT ]; then
    if [ -f "/config.xml.bak" ]; then
        if [ -f "$JENKINS_PERSIST/config.xml" ]; then
            rm $JENKINS_PERSIST/config.xml
        fi

        if [ -f "/config.xml" ]; then
            mv /config.xml /config.xml.bak
        fi

        mv /config.xml.bak /config.xml
    fi
fi

if [ ! -f "$JENKINS_PERSIST/config.xml" ]; then
    cp /config.xml $JENKINS_PERSIST/config.xml
fi

if [ ! -L "$JENKINS_PERSIST/plugins" ] || [ ! -d "$JENKINS_PERSIST/plugins" ]; then
    ln -s /plugins $JENKINS_PERSIST/plugins
fi

if [ ! -L "$JENKINS_HOME" ]; then
    rm -rf $JENKINS_HOME
    ln -s $JENKINS_PERSIST $JENKINS_HOME
fi

PARAMS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"
JENKINS_JAVA_ARGS='-Djava.awt.headless=true'

[ -n "$JENKINS_DEBUG_LEVEL" ] && PARAMS="$PARAMS --debug=$JENKINS_DEBUG_LEVEL"
[ -n "$JAVA_ARGS" ] && JENKINS_JAVA_ARGS="$JENKINS_JAVA_ARGS $JAVA_ARGS"

java $JENKINS_JAVA_ARGS -jar $JENKINS_WAR $PARAMS
