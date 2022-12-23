#
# The recommended shebang is #!/usr/bin/env bash, not #!/bin/bash
#
###
# Build:
# docker build . --tag toolbox-aws
# Run:
# docker run --rm -it toolbox-aws /bin/bash
###
# https://hub.docker.com/r/hashicorp/terraform
FROM hashicorp/terraform:1.2.5 as terraform
# https://hub.docker.com/_/node?tab=tags&page=2&name=17
FROM node:18-alpine AS node

FROM alpine:3.16

LABEL org.opencontainers.image.authors="cloudkats@gmail.com" \
    org.opencontainers.image.vendor="https://github.com/cloudkats" \
    org.opencontainers.image.title="cloudkats/toolbox-aws" \
    org.opencontainers.image.source="https://github.com/cloudkats/toolbox-aws" \
    org.opencontainers.image.demo="https://github.com/cloudkats/toolbox-aws/examples" \
    org.opencontainers.image.documentation="https://github.com/cloudkats/toolbox-aws/readme.md" \
    org.opencontainers.image.licenses="https://github.com/cloudkats/toolbox-aws/LICENCE" \
    org.opencontainers.image.tools="terraform terragrunt kubectl hel opa yq jq bats nodejs" \
    org.opencontainers.image.plugins="helm-diff"

COPY --from=terraform /bin/terraform /bin/terraform
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/bin /usr/local/bin

# renovate: datasource=github-releases depName=gruntwork-io/terragrunt
ENV TERRAGRUNT_VERSION=0.38.5
# renovate: datasource=github-releases depName=kubernetes-sigs/aws-iam-authenticator
ENV AWS_IAM_AUTHENTICATOR_VERSION=0.6.2
# renovate: datasource=github-tags depName=kubernetes/kubectl
ENV KUBECTL_VERSION=v1.20.15
# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=3.9.2
# renovate: datasource=github-releases depName=databus23/helm-diff
ARG HELM_DIFF_VERSION=3.5.0
# renovate: datasource=github-releases depName=kislyuk/yq
ARG YQ_VERSION=3.0.2
# renovate: datasource=github-releases depName=open-policy-agent/opa
ARG OPA_VERSION=0.42.2

ENV APK_PACKAGES="bash groff less python3 py3-pip curl ca-certificates jq git"

# hadolint ignore=DL3018,DL3013
RUN apk update && apk add --no-cache --virtual .build-deps \
    && apk -Uuv add --no-cache ${APK_PACKAGES} \
    && pip --no-cache-dir install awscli boto3 yq==${YQ_VERSION##*v} \
    && git clone https://github.com/bats-core/bats-core.git /opt/bats/ \
    && rm /var/cache/apk/*

RUN ln -s /usr/bin/python3 /usr/bin/python;\
    ln -s /opt/bats/bin/bats /usr/sbin/bats;

ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/bin/terragrunt
RUN chmod +x /usr/bin/terragrunt

# helm
RUN mkdir -p /tmp/helm \
    && curl -sL -o "/tmp/helm/${HELM_VERSION}.tar.gz" "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -zxvf "/tmp/helm/${HELM_VERSION}.tar.gz" -C /tmp/helm \
    && mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/helm
RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION}

# kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

# aws-iam-authenticator
RUN curl -sL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION##*v}_linux_amd64 -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

RUN curl -L -o /usr/local/bin/opa https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64_static \
    && chmod +x /usr/local/bin/opa

# ENV APK_PACKAGES="bash curl zip jq tree git make ca-certificates netcat"
# apk add --no-cache
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD ["/bin/bash"]
