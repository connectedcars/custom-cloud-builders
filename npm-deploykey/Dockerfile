FROM gcr.io/cloud-builders/npm:current

# Install ssh
RUN apt-get update -y && apt-get install --no-install-recommends -y -q openssh-client && \
    apt-get clean && rm /var/lib/apt/lists/*_*

COPY root /root
RUN chmod 600 /root/.ssh/id_rsa
RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

COPY usr /usr

ENV SSH_KEY_PASSWORD=
ENTRYPOINT ["/usr/local/bin/npmwrap.sh"]