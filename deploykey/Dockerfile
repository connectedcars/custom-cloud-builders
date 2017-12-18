FROM gcr.io/cloud-builders/gcloud

COPY init.sh /usr/local/bin/init.sh
COPY id_rsa.enc /root/id_rsa.enc
RUN chmod 755 /usr/local/bin/init.sh

ENV KMS_KEY_NAME=

ENTRYPOINT ["/usr/local/bin/init.sh"]