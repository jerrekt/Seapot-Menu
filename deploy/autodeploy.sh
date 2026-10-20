#!/usr/bin/env bash
# Runs every minute (seapot-menu-autodeploy.timer). Pulls main; applies only what changed.
set -euo pipefail
cd /opt/seapot-menu
git fetch -q origin main
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] && exit 0

changed=$(git diff --name-only HEAD origin/main)
git reset -q --hard origin/main
chmod -R a+rX /opt/seapot-menu
echo "deployed $(git log -1 --format='%h %s')"

if grep -q '^deploy/.*\.\(service\|timer\)$' <<<"$changed"; then
  cp deploy/*.service deploy/*.timer /etc/systemd/system/
  systemctl daemon-reload
fi
if grep -q '^deploy/nginx-seapot-menu.conf$' <<<"$changed"; then
  cp deploy/nginx-seapot-menu.conf /etc/nginx/sites-available/seapot-menu
  nginx -t && systemctl reload nginx
fi
