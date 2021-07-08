# Example repository for Axway CLI

## Purpose
The main aim of this repository is to illustrate how the APIM CLI works
in a CI/CD workload.

There are two branches, illustrating two different approaches.

* Branch `demo`: With pure 100% github actions integration, no fuss.
* Branch `makefiles`: Makefiles everywhere, the github workflows are but an invocation of make.

demo is the slickest one, with a focus on the apis and little to no control on how to publish the APIs, it relies only on the CI/CD

Makefiles on the other hand has more to chew, but the CI is a mere invocation of make, meaning that everything the CI does can be made locally, like generating files and publishing apis (even individually)

Both integrations will do broadly the same, one job per business that will :
* generate the expected configuration file [`api-config.json`](#api-config.json) for each api in it
* invoke the [apim-cli](#https://github.com/Axway-API-Management-Plus/apim-cli) on each api to import it in your API Manager.

You need to set some Github secrets on your repository for this to work. See [setup](#setup) for further instructions on how to do this.

## Setup

First, fork this repository.

### Prerequisites

#### A running and accessible API Manager
You are expected to have a running Axway API Manager, so that the APIM CLI can
interact with it and publish. Setting an Axway API Manager is beyond the scope of this documentation. 

Please take good note on the following information, as you will need it on the [setup](#setup) phase:
* The domain name and port of the Axway API Manager: This _must_ be an URL accessible on the Internet for this repository to work.
* The username and password of a user on the API. It can be the `apiadmin`, but depending on what you are trying to achieve, it can be a lesser privileged user.

#### (optional) Some softwares installed locally

You will need 
* a decently recent [version of Docker](https://docs.docker.com/get-docker/)
* a [NodeJS 16+ installation](https://nodejs.org/en/download/package-manager/)
* GNU Make

You can skip these if you do not plan on running make locally - in which case you are probably better off using the `demo` branch which offers the same features with less fuss. 

### Setting the secrets on GitHub
Then, create the following (GitHub secrets)[https://docs.github.com/en/actions/reference/encrypted-secrets] in your own fork:

| **Name**    | **Example**              | **Description**                               |
|-------------|--------------------------|-----------------------------------------------|
| `APIM_HOST` | `api-env.demo.axway.com` | The FQDN of where your Axway API Manager is located |
| `APIM_PORT` | `8075`                   | The port of your Axway API Manager                  |
| `APIM_USER` | `apiadmin`               |                                               |
| `APIM_PASS` | `changeme`               |                                               |

#### Your API Manager is accessible from the Internet
You are done. The Github acitons will be run by Github Runners, and they will be able to connect to your Axway API Manager correctly.

#### Your API Manager is _not_ accessible from the internet
The easier way to get going is to [host your own Github Actions Runner](https://docs.github.com/en/actions/hosting-your-own-runners).
This is well beyond the scope of this documentation.

Just note that your self-hosted runner :
* must be able to connect to the API Manager.
* must be able to access Github
* need not be accessible from the internet

The values for `APIM_HOST` and `APIM_PORT` should make sense _to your runner_. For example, if the runner and the API Manager are on the same machine, `APIM_HOST` can (and probably should) be valued to `localhost`.

In this setting, be aware that your runner becomes an important part of your CI/CD pipeline and should be monitored accordingly.

### Setting the secrets locally

To be able to publish your apis locally from the command line, you need a file that contains your secrets: Those from GitHub cannot be accessed simply on your computer.

First run `make init`.
This will install the needed NodeJS modules (needed to create some configuration files), and create a file named `.local.env` at the root of your project.
This file is filled with some lines which resemble some bash variables declarations (but are not, they are Make variables which are very alike).  
You can edit this file to your needs, this is purely a local file and will not be commited.

You could e.g. set the `APIM_HOST` to `localhost` if you need to test the effect of your apis on a local instance.
You can of course set all the variables to the same values as in the Github secrets.
It would allow you to run exactly the same commands that the CI would. 

Please note that the value of an environment variable will take precedence on the values defined on `.local.env` (this is what the `=?`means in the file). 

### Testing the setup

#### Testing the CI/CD part

To test your setup, execute the `test-ci.sh` at the root of the project.
This will basically create a test branch, a test workflow and push the whole thing to your repository, wait a bitto let you check that the workflow is run correctly, then delete this test branch.

The expected outcome is that a workflow listing the apis known to the API Manager is triggered.
This would confirm that the secrets and the connectivity from the runners and the API Manager are in place.

#### Testing the local environment
At the root of the project, execute 

    $ make probe

The expected outcome is a tabular listing of the apis in the API Manager pointed by your `.local.env` file.

## Usage

### CI/CD as normal
Commit and push as usual.  
Each push will trigger a publication of a given business if:
* you are on branch `makefiles`
* one file in the business has changed in any way.
* the last commit of the push does not contain the token `[SKIP-CI]` in its comment.

Have a look at [a workflow example](#workflow) to understand how it works under the hood.

### run things locally
This is the main benefit of this layout. If you see no value in this paragraph, you should probably use the `demo` branch instead.

You can execute three different goals on make, on three different levels.  
Executing a goal on a folder, and it will descend the subfolders.
So executing `make clean`on the root folder will `make clean` every API for instance.
Boringly hierarchical... 

The possible goals are:
* `clean`: the generated files are removed. You can run it fearlessly to get rid of useless files.
* `gen`: The [`gen.api-config.json`](#api-config.json) are generated. You can run that to see exactly what file is given to the apim-cli and see for yourself what you can tune.  
Do run `clean` before as a general precaution, as the generation will not overwrite an existing file.
* `publish`: `gen` is executed if needed, then the api is published to the API Manager.  

Now to recreate what the CI/CD would do on e.g. couponing, execute the following:

    $ cd couponing
    $ make publish

This is what the CI/CD will do.
We suggest that you execute `make clean publish` to get files generated afresh, or even `make -j clean && make -j publish` if you don't fear some gibberish logs... Everything will run in parallel - hence faster overall - but all logs for all jobs will be intertwined - hence unreadable for a mortal.

__Possible caveats:__
* Version of NodeJS: In the CI/CD, we require NodeJS v16. You might have something different locally, but it should not pose any major issue.
* Version of Docker: To run the APIM-CLI consistently, we rely on a Docker container.
Any recent version of Docker should do the job consistently with what the CI/CD would execute, but regardless, your version will probably differ from the one on the runner and this could cause some discrepancies.

## Layout of the project

This project is layed out this way

    .
    ├── <boilerplate>
    ├── Makefile
    ├── package.json, package-lock.json
    ├── <business>
    │   ├── <api>
    │   │   ├── api-config-tpl.json
    │   │   ├── api-image.jpg
    │   │   └── api-spec.yaml
    │   ├── defaults.json
    │   └── Makefile
    └── .github
        └── workflows
            └── publish-<business>.yml

For instance, there are 4 businesses: `couponing`, `health_authority`, `insurtech`, `iot`.  
In `couponing`, you will find 4 apis: `amazon`, `decathlon`, `nike`, `puma`

### `<boilerplate>`

* `README.MD`, `LICENCE.MD`,`.gitignore` which are usual
* `.gitignore` which excludes [`api-config.json`](#api-config.json) (more on that later) 

### `Makefile`
There is a lot of witchery in any Makefile. You can read these, but you should refrain from modifying them (unless you know what you are doing, in which case this author is deeply interrested about whatever enhancements you might suggest).

### `package.json`, `package-lock.json`, `node_modules`

We need `json-merger` to generate the [`api-config.json`](#api-config.json) file.
Since this is a nodejs piece, having these two files is the most simple way to make it readily available for us on the CI/CD pipeline.
It is possible that you never see the `node_modules` directory. Don't worry, its a technicality and can be safely ignored.

### <a name="business"></a>`<business>`
A line of business, with a folder per API that must be exposed for this business.

### <a name="api"></a>`<api>`
One single API that we want to deal here.
In this folder, we can find a set of important files, see below.

### `api-config-tpl.json`, `gen.api-config.json`, `defaults.json`
<a name="api-config-tpl.json"></a><a name="api-config.json"></a><a name="defaults.json"></a>
`api-config-tpl.json` is a template that is merged with `defaults.json` to produce  `api-config.json`, which is the main configuration to the apim-cli.
Example:

`defaults.json`

    {
      "name": "",
      "path": "",
      "state": "published",
      "version": "",
      "organization": "API Development",
      "apiDefinition": "api-spec.yaml",
      "backendBasepath": "http://ptx136.demo.axway.com:8081/",
      "image": "api-image.jpg",
      "securityProfiles": [
        {
          "name": "_default",
          "isDefault": true,
          "devices": [
            {
              "name": "API Key",
              "type": "apiKey",
              "order": 1,
              "properties": {
                "apiKeyFieldName": "KeyId",
                "takeFrom": "HEADER",
                "removeCredentialsOnSuccess": "true"
              }
            }
          ]
        }
      ],
      "clientOrganizations": [
        "API Development"
      ]
    }

`api-config-tpl.json`

    {
      "$merge": {
        "source": {
          "$import": "../defaults.json"
        },
        "with": {
          "name": "Good Food Good Life",
          "summary": "",
          "path": "/gfgl",
          "version": "1.0"
        }
      }
    }

`gen.api-config.json`

    {
      "name": "Good Food Good Life",    # <- FROM api-config-tpl.json
      "path": "/gfgl",                  # <- FROM api-config-tpl.json
      "state": "published",     
      "version": "1.0",                 # <- FROM api-config-tpl.json
      "summary": ""                     # <- FROM api-config-tpl.json
      "organization": "API Development",
      "apiDefinition": "api-spec.yaml",
      "backendBasepath": "http://ptx136.demo.axway.com:8081/",
      "image": "api-image.jpg",
      "securityProfiles": [
        {
          "name": "_default",
          "isDefault": true,
          "devices": [
            {
              "name": "API Key",
              "type": "apiKey",
              "order": 1,
              "properties": {
                "apiKeyFieldName": "KeyId",
                "takeFrom": "HEADER",
                "removeCredentialsOnSuccess": "true"
              }
            }
          ]
        }
      ],
      "clientOrganizations": [
        "API Development"
      ]
    }

The rest of fileds maps more or less one to one with those of the screens in the API Manager to create a ew frontend/backend pair.

### <a name="api-image.jpg"></a>`api-image.jpg`
Referenced by [`api-image.json`](#api-image.json): The image that will serve as an avatar for the API.

### <a name="api-spec.yaml"></a>`api-spec.yaml`
Referenced by [`api-config.json`](#api-config.json): The OpenAPI/Swagger definition for the API.

### .github / workflows
Where Github workflows live. A workflow is triggered in response of a whole lot of events in the life of a repository/project.
Each file here will be evaluated on every new event.

### <a name="workflow"></a>`publish-<business>.yml`
Lets have a look at an example; all are alike anyways.

    name: Deploy all couponing APIs

    on:
      push:
        branches:
          - makefiles
        paths: "couponing/**"

    jobs:
      API-Deployment:
        if: "!contains(github.event.head_commit.message, '[SKIP-CI]')" 
        runs-on: ubuntu-latest
        steps:
          - name: Checkout the git repository
            uses: actions/checkout@v2
          - name: Use Node.js 16
            uses: actions/setup-node@v2
            with:
              node-version: 16
          - name: Prepare workspace
            run: make init
          - name: Publish couponing APIs
            env:
              APIM_USER: ${{ secrets.APIM_USER }}
              APIM_PASS: ${{ secrets.APIM_PASS }}
              APIM_HOST: ${{ secrets.APIM_HOST }}
              APIM_PORT: ${{ secrets.APIM_PORT }}
            run: make -C couponing publish

Breaking this down:

   name: Deploy all Couponning APIs

    on:
      push:
        branches:
          - makefiles
        paths: couponing/**

Give a name to the workflow, and mark interrest on push events that registers a modification on business `couponing` on branch `makefile` only.

    jobs:
      API-Deployment:
        if: "!contains(github.event.head_commit.message, '[SKIP-CI]')" 
        runs-on: ubuntu-latest

Configuring the jobs we are running. Here, we will run every steps for each api un parallel (matrix strategy does that). Steps will run in the latest ubuntu OS, and only if the last commit of the push we are dealing with does not have `[SKIP-CI]` in its commit message.

    steps:
      - name: Checkout the git repository
        uses: actions/checkout@v2
      - name: Use Node.js 16
        uses: actions/setup-node@v2
        with:
          node-version: 16

First step is about checking out our repository and getting NodeJS v16 in scope.

      - name: Prepare workspace
        run: make init
      - name: Publish couponing APIs
        env:
          APIM_USER: ${{ secrets.APIM_USER }}
          APIM_PASS: ${{ secrets.APIM_PASS }}
          APIM_HOST: ${{ secrets.APIM_HOST }}
          APIM_PORT: ${{ secrets.APIM_PORT }}
        run: make -C couponing publish

Lastly, we run `make publish` inside the `couponing` subfolder. The `env` part maps each secret to an environment variable with the same name. This is the same stitching that the .local.env does.