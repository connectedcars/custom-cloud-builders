# custom-cloud-builders

Custom container builders for google cloud builder

## Usage

Create KSM encryption key for encrypting the deploy key:

``` bash
gcloud kms keyrings create cloudbuilder --location=global
```

``` bash
gcloud kms keys create github-deploykey --location=global --keyring=cloudbuilder --purpose=encryption
```

Create the deploy key and add public key to github private repo:

``` bash
ssh-keygen -f id_rsa
```

Encrypt private key and base64 so it can be added as secureEnv:

``` bash
gcloud kms encrypt --plaintext-file=id_rsa --ciphertext-file=id_rsa.enc  --location=global --keyring=cloudbuilder --key=github-deploykey
```

## Build images

``` bash
gcloud container builds submit --config=cloudbuild.yaml .
```