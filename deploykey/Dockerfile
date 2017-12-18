FROM gcr.io/cloud-builders/gcloud

COPY usr /usr
COPY root /root

# Install ssh
RUN apt-get update -y && apt-get install --no-install-recommends -y -q openssh-client && \
    apt-get clean && rm /var/lib/apt/lists/*_*

RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

ENV KMS_KEY_NAME=

ENTRYPOINT ["/usr/local/bin/init.sh"]