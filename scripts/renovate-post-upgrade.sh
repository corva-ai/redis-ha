#!/usr/bin/env sh
# Regenerate README.md after Renovate bumps values.yaml / Chart.yaml.
#
# Invoked by Renovate's postUpgradeTasks (see renovate.json). The command path
# must match the allowedCommands list in corva-ai/corva-renovate
# (src/config.base.ts). Keep HELM_DOCS_VERSION in sync with
# .github/workflows/lint.yml and .pre-commit-config.yaml.

set -eu

HELM_DOCS_VERSION="${HELM_DOCS_VERSION:-1.14.2}"

cd "$(dirname "$0")/.."

if command -v helm-docs >/dev/null 2>&1; then
  helm_docs=helm-docs
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  os="$(uname -s)"
  arch="$(uname -m)"
  case "$arch" in
    aarch64) arch=arm64 ;;
  esac
  url="https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_${os}_${arch}.tar.gz"
  echo "helm-docs not found on PATH, downloading ${url}"
  curl -fsSL "$url" | tar -xz -C "$tmp" helm-docs
  helm_docs="$tmp/helm-docs"
fi

"$helm_docs" --chart-search-root=. --template-files=README.md.gotmpl
echo "README.md regenerated with helm-docs ${HELM_DOCS_VERSION}"
