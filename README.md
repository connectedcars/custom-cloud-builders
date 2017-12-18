# custom-cloud-builders

Custom container builders for Google cloud builder

## Usage

### Options 1

This options lets cloud builder decrypt a password for the ssh deploy key and then injects the key it into a ssh-agent running in the same container as the npm command.

``` yaml
steps:
  # Install the dependencies with deploy key
  - name: 'gcr.io/$PROJECT_ID/npm-deploykey-<KEY NAME>:current'
    args: ['install']
    secretEnv: ['SSH_KEY_PASSWORD']
  # Do normal build steps
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/hello-world:latest', '.']
secrets:
- kmsKeyName: projects/<PROJECT NAME>/locations/global/keyRings/cloudbuilder/cryptoKeys/github-deploykey
  secretEnv:
    SSH_KEY_PASSWORD: <BASE64 ENCODED ENCRYPTED PASSWORD>
```

### Option 2

This options uses the "gcloud kms decrypt" tool and puts the decrypted key in a volume, this is then mounted in all containers that need the key.

``` yaml
steps:
  # Install the deploy in /root/.ssh
  - name: 'gcr.io/$PROJECT_ID/deploykey:latest'
    env: ['KMS_KEY_NAME=$PROJECT_ID/global/cloudbuilder/github-deploykey']
    volumes:
      - name: 'deploykey'
        path: /root/.ssh
  # Install the dependencies with deploy key
  - name: 'gcr.io/$PROJECT_ID/npm-ssh:current'
    args: ['install']
    volumes:
      - name: 'deploykey'
        path: /root/.ssh
  # Do normal build steps
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/hello-world:latest', '.']
```

## Setup

Create KSM encryption key for encrypting the deploy key or key password:

``` bash
gcloud kms keyrings create cloudbuilder --location=global
```

``` bash
gcloud kms keys create github-deploykey --location=global --keyring=cloudbuilder --purpose=encryption
```

### Option 1 (ssh-agent in npm container)

Add the key to new container that inherits from npm-deploykey:

Dockerfile:

``` docker
FROM gcr.io/<PROJECT>/npm-deploykey:current

COPY root /root
RUN chmod 600 /root/.ssh/id_rsa
```

Create the deploy key and add public key to github private repo:

``` bash
mkdir -p root/.ssh
ssh-keygen -f root/.ssh/id_rsa # Set long random password
```

Encrypt password and base64 it so it can be added to secureEnv:

### Option 2 (shared id_rsa key with volume mounts)

Add the key to new container that inherits from deploykey:

Dockerfile:

``` docker
FROM gcr.io/<PROJECT>/npm-deploykey:current

COPY root /root
```

``` bash
mkdir -p root/.ssh
ssh-keygen -f root/.ssh/id_rsa # Don't set any password
gcloud kms encrypt --plaintext-file=root/.ssh/id_rsa --ciphertext-file=root/.ssh/id_rsa.enc  --location=global --keyring=cloudbuilder --key=github-deploykey
rm -f root/.ssh/id_rsa
```

## Build images for testing

``` bash
docker build -t npm-deploykey:latest ./ && docker run -e 'SSH_PASSWORD=mypassword' --rm -it npm-deploykey:latest
```

``` bash
gcloud container builds submit --config=cloudbuild.yaml .
```