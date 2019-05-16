Serverless Pact Broker
==================

This repository deploys [Pact Broker](https://github.com/pact-foundation/pact_broker) using as an AWS Lambda function along with API Gateway using Serverless.

## Prerequisites

* A running postgresql database and the ability to connect to it (see [POSTGRESQL.md][postgres]).
* An AWS account
* A custom domain in route 53 with a certificate

## Getting Started

1. [Install Docker](https://docs.docker.com/engine/installation/)
2. Prepare your environment if you are not running postgresql in a docker container. Setup the pact broker connection to the database through the use of the following environment variables.
    <!-- If you want to use a disposable postgres docker container just do `export DISPOSABLE_PSQL=true` before running the [script/test.sh][test-script]. -->

For a postgres database

    * PACT_BROKER_DATABASE_USERNAME
    * PACT_BROKER_DATABASE_PASSWORD
    * PACT_BROKER_DATABASE_HOST
    * PACT_BROKER_DATABASE_PORT (optional, defaults to the 5432)
    * PACT_BROKER_DATABASE_NAME

<!-- 1. Test the pact broker environment by executing [script/test.sh][test-script] -->

## Serverless setup

* `README.md`- this file
* `Makefile` - useful commands to run everything
* `build-withpg.sh` - a build file to compile the gem dependencies and postgres in your function
* `build-withpglayer.sh` - a build file to compile the gem dependencies and utilise postgres via an aws layer, creatable in the rubypg_layer folder.
* `serverless.yml` - A file to deploy the application using Serverless
* `rubypg_layer` - an aws layer template to provide an aws base with postgres dependencies satisfied
* `.slsignore` - .gitignore style file to exclude files from packaged deployment artefacts
* `.env.example` - for your secrets, rename to `.env` and fill out with your variables

## Serverless Plugins

plugins:
  - serverless-rack - A ruby handler to provide a translation between lambda functions and our rack middleware
  - serverless-ignore - A .gitignore like file to exclude files from your serverless deployment package.
  - serverless-domain-manager - A way to map your function to a cloud 53 hosted domain name

## Running with Serverless

1. Run `make downloadpb` which will download the latest version of the `pact_broker` folder from `pact-foundation/pact-broker-docker` _note_ this command will remove the old folder without futher warning.
2. Run `make packagewithpg` to build the pact broker bundle dependencies and postgres dependencies in a docker container, and copy them to your `vendor` and `lib` folders.
   Alternatively you can run `make package` to build the pact broker bundle dependencies. You will need a custom aws layer with the postgres dependencies satisfied to run your function successfully. See the next section
3. Run `yarn install` or delete the `.lock` file and run `npm install` if you prefer. This will install serverless, along with serverless-rack, serverless-ignore & serverless-domain-manager.

  ```ruby
    app = PactBroker::App.new do | config |
      config.log_dir = "/tmp/log"
      ...
    end
  ```

5. Run `make deploy` to deploy your function, and you will receive a URL at the end if everything went OK.

6. Run `make logs` to access the aws lambda logs from cloudwatch, you will need to curl your endpoint or load it in the browser to initiate a request after deployment (and see anything useful in the logs)
   
## Mapping a custom domain to your function

If you have a route 53 domain setup, you can use serverless-domain-manager to map your to your domain.

1. In the root `serverless-yml`, we have a custom domain section

   
```yml
  customDomain:
    domainName: ${env:SERVERLESS_DOMAIN_NAME}
    certificateName: ${env:SERVERLESS_CERTIFICATE_NAME}
    stage: dev
    createRoute53Record: true
```
These are read in via env vars

```
SERVERLESS_DOMAIN_NAME=you54f.co.uk
SERVERLESS_CERTIFICATE_NAME=you54f.co.uk
PACT_BROKER_BASE_URL=https://$SERVERLESS_DOMAIN_NAME
```

We need to pass the domain name into the pact broker app via `PACT_BROKER_BASE_URL`.

2. You will need a user with permissions to update route53 records, a template is provided in `serverless.domain.yml`, you can run this in via cloudformation.


## Creating a custom AWS layer with Postgres dependencies satisfied

1. Run `make pglayer` to build the postgres dependencies in a docker container and save them back to your host in the `lib` folder.
2. Run `deploy pglayer` to deploy it to AWS. Note the ARN address outputted to the console.
3. In the root folder, update `.env.example` to `.env` and set the following env var `PG_RUBY_LAYER_ARN=arn:aws:lambda:eu-west-2:************:layer:pgRuby25:1` to the value in step 2
4. In the root `serverless-yml`, we read the env var `PG_RUBY_LAYER_ARN` which contains the ARN recorded in the previous step. Uncomment this section out.
   
```yml
    layers:
      - ${env:PG_RUBY_LAYER_ARN}
```

## Notes

* The application makes use of Rack via Serverless-Rack

## Using basic auth

To enable basic auth, run your container with:

* `PACT_BROKER_BASIC_AUTH_USERNAME`
* `PACT_BROKER_BASIC_AUTH_PASSWORD`
* `PACT_BROKER_BASIC_AUTH_READ_ONLY_USERNAME`
* `PACT_BROKER_BASIC_AUTH_READ_ONLY_PASSWORD`

Developers should use the read only credentials on their local machines, and the CI should use the read/write credentials. This will ensure that pacts and verification results are only published from your CI.

Note that the [verification status badges][badges] are not protected by basic auth, so that you may embed them in README markdown.

## Heartbeat URL

If you need to make a heartbeat URL publicly available, set `PACT_BROKER_PUBLIC_HEARTBEAT=true`. No database connection will be made during the execution of this endpoint.

## Using SSL

SSL is provided as default with the API Gateway

## Setting the log level

Set the environment variable `PACT_BROKER_LOG_LEVEL` to one of `DEBUG`, `INFO`, `WARN`, `ERROR`, or `FATAL`.

## Webhook whitelists

* PACT_BROKER_WEBHOOK_HOST_WHITELIST - a space delimited list of hosts (eg. `github.com`), network ranges (eg. `10.2.3.41/24`, or regular expressions (eg. `/.*\\.foo\\.com$/`). Regular expressions should start and end with a `/` to differentiate them from Strings. Note that backslashes need to be escaped with a second backslash. Please read the [Webhook whitelists](https://github.com/pact-foundation/pact_broker/wiki/Configuration#webhook-whitelists) section of the Pact Broker configuration documentation to understand how the whitelist is used. Remember to use quotes around this value as it may have spaces in it.
* PACT_BROKER_WEBHOOK_SCHEME_WHITELIST - a space delimited list (eg. `http https`). Defaults to `https`.

## Other environment variables

* PACT_BROKER_BASE_EQUALITY_ONLY_ON_CONTENT_THAT_AFFECTS_VERIFICATION_RESULTS - `true` by default, may be set to `false`.
* PACT_BROKER_ORDER_VERSIONS_BY_DATE - `true` by default, may be set to `false`.
* PACT_BROKER_DISABLE_SSL_VERIFICATION - `false` by default, may be set to `true`.

## General Pact Broker configuration and usage

Documentation for the Pact Broker application itself can be found in the Pact Broker [wiki][pact-broker-wiki].

# Troubleshooting

See the [Troubleshooting][troubleshooting] page on the wiki.

[badges]: https://github.com/pact-foundation/pact_broker/wiki/Provider-verification-badges
[troubleshooting]: https://github.com/DiUS/pact_broker-docker/wiki/Troubleshooting
[postgres]: https://github.com/DiUS/pact_broker-docker/blob/master/POSTGRESQL.md
[test-script]: https://github.com/DiUS/pact_broker-docker/blob/master/script/test.sh
[docker-compose]: https://github.com/DiUS/pact_broker-docker/blob/master/docker-compose.yml
[pact-broker-wiki]: https://github.com/pact-foundation/pact_broker/wiki
[reverse-proxy]: https://github.com/pact-foundation/pact_broker/wiki/Configuration#running-the-broker-behind-a-reverse-proxy
