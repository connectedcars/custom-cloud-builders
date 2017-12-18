FROM gcr.io/cloud-builders/npm:current

# Install ssh
RUN apt-get update -y && apt-get install --no-install-recommends -y -q openssh-client && \
    apt-get clean && rm /var/lib/apt/lists/*_*
