# Custom Hermes Agent image: upstream + gh (GitHub CLI)
FROM nousresearch/hermes-agent:latest

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    install -dm 0755 /etc/apt/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    arch="$(dpkg --print-architecture)"; \
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends gh; \
    rm -rf /var/lib/apt/lists/*; \
    gh --version

# gh credentials persist on the Hermes data volume so `gh auth login`
# survives container restarts and image upgrades.
ENV GH_CONFIG_DIR=/opt/data/gh-config

# Hand back to the upstream entrypoint, which switches to the hermes user
# and applies HERMES_UID/HERMES_GID remapping.
USER root
