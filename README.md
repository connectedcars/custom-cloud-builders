# custom-cloud-builders

Custom container builders for Google cloud builder

## Usage

Options 1:

``` yaml
steps:
  # Install the dependencies with deploy key
  - name: 'gcr.io/$PROJECT_ID/npm-deploykey:current'
    args: ['install']
    secretEnv: ['SSH_KEY_PASSWORD']
  # Do normal build steps
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/hello-world:latest', '.']
secrets:
- kmsKeyName: projects/connectedcars-staging/locations/global/keyRings/cloudbuilder/cryptoKeys/github-deploykey
  secretEnv:
    SSH_KEY_PASSWORD: CiQAiXqwBmhqi+Od146HAG9E3cNiaCEzqkBl6X9hTatGe8B6b3kSUgCbUdOQElBUoff8hJBS5ouLnn93D26YGUvZT6Hcxcx+5JtO6FgYhoWg4aMFIGu98E1qcRUMTeoybPD4NyIG6MEL1kf8/qrtE0652YUiVjVAZ1c=
```

Option 2:

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

Create KSM encryption key for encrypting the deploy key:

``` bash
gcloud kms keyrings create cloudbuilder --location=global
```

``` bash
gcloud kms keys create github-deploykey --location=global --keyring=cloudbuilder --purpose=encryption
```

Create the deploy key and add public key to github private repo:

``` bash
ssh-keygen -f id_rsa # Option 1 requires that a password is set and Option 2 that no password is set
```

### Option 1 (ssh-agent in npm container)

This options lets cloud builder decrypt a password for the ssh deploy key and then injects it into a ssh-agent running in the same container as npm command.

Add the key to new container that inherits from npm-deploykey:

``` docker
FROM gcr.io/cloud-builders/npm-deploykey:current

COPY root /root
RUN chmod 600 /root/.ssh/id_rsa
```

Encrypt private key and base64 so it can be added as secureEnv:

``` bash
gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=cloudbuilder --key=github-deploykey | base64
```

### Option 2 (shared id_rsa key with volume mounts)

This options uses the gcloud kms decrypt tool and puts the key in volume(/root/.ssh), this is then mounted in all containers that need the key.

Encrypt private key:

``` bash
gcloud kms encrypt --plaintext-file=id_rsa --ciphertext-file=id_rsa.enc  --location=global --keyring=cloudbuilder --key=github-deploykey
```

## Build images for testing

``` bash
docker build -t npm-deploykey:latest ./ && docker run 'SSH_PASSWORD=mypassword' --rm -it npm-deploykey:latest
```

``` bash
gcloud container builds submit --config=cloudbuild.yaml .
```