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
    gh --version; \
    ln -sf /opt/hermes/.venv/bin/hermes /usr/local/bin/hermes

# Pre-install the WhatsApp (Baileys) bridge npm deps at BUILD time. The gateway
# checks for scripts/whatsapp-bridge/node_modules at startup and only runs
# `npm install` if it's missing (whatsapp.py). Baking it into the image (which
# is where the bridge lives — NOT the /opt/data volume) makes every container
# start skip that slow install step.
RUN cd /opt/hermes/scripts/whatsapp-bridge \
    && (npm ci --silent || npm install --silent) \
    && test -d node_modules

# gh credentials persist on the Hermes data volume so `gh auth login`
# survives container restarts and image upgrades. The hermes user creates
# this dir itself on first `gh auth login`, so it owns it (no root chown).
ENV GH_CONFIG_DIR=/opt/data/gh-config

# IMPORTANT: do NOT override ENTRYPOINT. The upstream image uses s6-overlay;
# its real entrypoint is /init, which bootstraps s6 AND execs the CMD.
# Overriding it (with docker/entrypoint.sh) breaks startup and the container
# crash-loops with "s6-setuidgid: not found". We only add packages here.
