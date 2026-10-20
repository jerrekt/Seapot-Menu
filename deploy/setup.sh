#!/usr/bin/env bash
# One-time setup on the menu-server LXC (CT 202). Run as root.
# Afterwards, every push to main is live within ~1 minute.
set -euo pipefail
REPO=git@github.com:jerrekt/seapot-menu.git
DIR=/opt/seapot-menu
KEY=/root/.ssh/seapot_menu_deploy
HOST=menu.adsuaracloud.com

if [[ "$(hostname)" != "menu-server" ]]; then
  read -rp "Hostname is $(hostname), not menu-server. Continue anyway? [y/N] " a; [[ $a == y ]] || exit 1
fi

echo "==> Packages"
apt-get update -qq
apt-get install -y -qq git openssh-client nginx curl >/dev/null

echo "==> Deploy key (separate from jerrekts-bar — GitHub deploy keys are per-repo)"
mkdir -p /root/.ssh && chmod 700 /root/.ssh
[[ -f $KEY ]] || ssh-keygen -q -t ed25519 -N "" -C "menu-server seapot-menu deploy" -f "$KEY"
ssh-keyscan github.com >> /root/.ssh/known_hosts 2>/dev/null || true
sort -u /root/.ssh/known_hosts -o /root/.ssh/known_hosts
echo
echo "Add this as a READ-ONLY deploy key:"
echo "  github.com/jerrekt/seapot-menu -> Settings -> Deploy keys -> Add deploy key"
echo
cat "$KEY.pub"
echo
read -rp "Press Enter once the key is added... "

echo "==> Clone"
export GIT_SSH_COMMAND="ssh -i $KEY -o IdentitiesOnly=yes"
if [[ -d $DIR/.git ]]; then git -C "$DIR" pull -q; else git clone -q "$REPO" "$DIR"; fi
git -C "$DIR" config core.sshCommand "ssh -i $KEY -o IdentitiesOnly=yes"
chmod -R a+rX "$DIR"

echo "==> Auto-deploy timer"
cp "$DIR"/deploy/*.service "$DIR"/deploy/*.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable -q --now seapot-menu-autodeploy.timer

echo "==> Back up the old manual copy"
[[ -d /var/www/html ]] && cp -a /var/www/html /root/menu-backup-$(date +%F) && echo "    saved to /root/menu-backup-$(date +%F)"

echo "==> nginx"
cp "$DIR"/deploy/nginx-seapot-menu.conf /etc/nginx/sites-available/seapot-menu
ln -sf /etc/nginx/sites-available/seapot-menu /etc/nginx/sites-enabled/seapot-menu
nginx -t -q && systemctl reload nginx

echo "==> Smoke test"
sleep 1
echo "    menu $(curl -s -o /dev/null -w '%{http_code}' -H "Host: $HOST" http://127.0.0.1/)"
echo "==> Auto-deploy is on. Logs: journalctl -u seapot-menu-autodeploy -n 20"
