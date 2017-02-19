# awsenv
Manage shell env vars for multiple AWS accounts.  Also provides automatic API key rotation after a configurable period of time.

The provided utilities leverage the awscli tools, and scripts written in Python 3, so ensure that the awscli Python package is
installed where your Python 3 runtime can access it (`pip3 install awscli`)

It also uses the configuration files provided by the awscli tools to store configuration.  This means that settings and credentials
are stored under $HOME/.aws

## Installation
  1. Copy the files under the `bin` directory to some place in your PATH ($HOME/bin would be a good start)
  2. Copy the files under the `profile.d` directory somewhere they will be sourced during shell initialization:
    * A global /etc/profile.d directory
    * A per-user $HOME/.profile.d directory
  3. Add the contents of the prompt_command file to the user's .bashrc file (customize paths and profile names as needed)

## Configuration
The first thing you'll want to do is set the default profile region and credential lifetime values:
  * aws configure set region us-east-1 --profile default
  * aws configure set aws_api_key_lifetime_hours 15 --profile default

It would also be helpful to define the credentials (this assumes the credentials are already part of your env):
  * aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile default
  * aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile default

Repeat adding credentials for other profiles/accounts by changing the value of th `--profile` option.  This utility also
exposes any configuration in $HOME/.aws/config for a given profile as env vars, so it would be useful to add that info, if needed:
  * aws configure set aws_iam_user_name my_iam_user --profile default
