#!/bin/sh

if [ $TZ ]
then
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
fi

if [ $HUBOT_SLACK_TOKEN_FILE ]
then
    export HUBOT_SLACK_TOKEN=`cat $HUBOT_SLACK_TOKEN_FILE`
fi

./bin/hubot --adapter slack
