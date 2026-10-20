# Seapot Menu

Customer menu for Seapot Korean BBQ & Hot Pot — **https://menu.adsuaracloud.com**
Staff bar guide lives in [`jerrekt/seapot-bar`](https://github.com/jerrekt/seapot-bar).

## Layout
- `site/index.html` — the menu (time-based Lunch/Dinner pricing; test with `?mode=lunch` / `?mode=dinner`)
- `deploy/` — nginx config, systemd units, setup + auto-deploy scripts

## Deploy
Hosted on the `menu-server` LXC (CT 202, Adsuara), behind the `seapot-menu-sj` Cloudflare Tunnel.
A systemd timer pulls `main` every minute and applies changes — push to deploy.

First-time server setup: `deploy/setup.sh` (backs up `/var/www/html` first).
