# hermes-agent-image

Thin layer on top of `nousresearch/hermes-agent:latest` that adds the
GitHub CLI (`gh`). The Hermes built-in `github-*` skills (PR review,
issues, repo management) shell out to `gh`, so they require this image.

`gh` config is pointed at `/opt/data/gh-config` so credentials persist
on the Hermes data volume.

## Use with Coolify Docker Compose

```yaml
services:
  hermes-gateway:
    build:
      context: https://github.com/Saad5400/hermes-agent-image.git#main
```
