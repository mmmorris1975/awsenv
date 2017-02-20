#!/bin/bash

if [ ! -d ~/.aws ]
then
  mkdir ~/.aws
  touch ~/.aws/credentials
fi

chmod 600 ~/.aws/credentials
chmod 750 ~/.aws

export AWS_REGION=${AWS_DEFAULT_REGION:=`aws configure get region --profile default`}
export AWS_DEFAULT_REGION

function awsenv {
  rand=$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | cksum | awk '{print $1}')
  file=/tmp/.aws_cred_${1}_${USER}_$(date +%s)_${rand}
  touch $file && chmod 600 $file

  if [ `which awscli_config_parser` ]
  then
    awscli_config_parser $1 >$file
    source $file
  else
    echo "ERROR: Unable to find credentials for AWS Environment $1"
  fi

  rm -f $file

  export AWS_DEFAULT_PROFILE=$1
}

function rotate_api_keys {
  AWS_API_KEY_LIFETIME=$((${AWS_API_KEY_LIFETIME_HOURS} * 3600))
  file=/tmp/.aws_credentials_expiration_${AWS_DEFAULT_PROFILE}_${USER}

  if [ ! -f $file ]
  then
    echo $((`date +%s` + $AWS_API_KEY_LIFETIME)) >$file
  fi

  if [ `date +%s` -gt `cat $file` ]
  then
    if [ ! -f ${file}.lock ]
    then
      echo `date +%s` >${file}.lock

      echo "!!! IT'S TIME TO ROTATE THE AWS KEYS FOR PROFILE: $AWS_DEFAULT_PROFILE !!!"
      new_keys=$(aws_api_key_rotate 2>/dev/null | grep ':' | tail -1)

      aws configure set aws_access_key_id $(echo $new_keys | cut -d ':' -f 1) --profile $AWS_DEFAULT_PROFILE
      aws configure set aws_secret_access_key $(echo $new_keys | cut -d ':' -f 2) --profile $AWS_DEFAULT_PROFILE

      echo $((`date +%s` + $AWS_API_KEY_LIFETIME)) >$file
      rm -f ${file}.lock
    fi
  fi
}
