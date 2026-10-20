# seapot-menu — notes for Claude

Customer menu for Seapot Korean BBQ & Hot Pot (Sunnyvale) → https://menu.adsuaracloud.com
Owner: BJ (GitHub `jerrekt`). Sister sites: `jerrekt/seapot-bar` (staff bar guide), `jerrekt/jerrekts-bar` (home bar).

## Rules
- **Only `git push` when BJ says "push".** Commit locally, show a preview/screenshot, then wait.
- Keep chat replies short.
- The 21+ Bar section here and the staff guide (`seapot-bar`) must stay in sync — any new drink or price change goes in **both** repos.
- Item descriptions (e.g. hot pot meats) were picked by BJ — don't rewrite copy unilaterally; offer options and let him choose.
- **Never change URLs.** Printed QR codes and 3D-printed QR chips point to `menu.adsuaracloud.com`; the Branden QR points to `/branden`.

## Layout
- `site/index.html` — the whole menu (single file, inline CSS/JS).
  - Time-based pricing (Pacific time): Lunch Mon–Fri 11–4 shows Lunch+Silver+Gold; otherwise Silver+Gold. Test with `?mode=lunch|dinner`.
  - `/branden` = same page with Branden's picks tagged. Picks list is the `PICKS` array in the script (names must match item text exactly; Jerrekt Mix soju is added in code). Test locally with `?picks=1`.
- `deploy/` — nginx site, systemd autodeploy service+timer, `setup.sh` (one-time).

## Hosting
- Proxmox node Adsuara → LXC **CT 202 `menu-server`** (unprivileged, 1 core, 512 MB, onboot, backed up).
- nginx serves all three sites from `/opt/<repo>/site`; this repo's server block is `menu.adsuaracloud.com` (also handles `/branden/`).
- Auto-deploy: `seapot-menu-autodeploy.timer` pulls `main` every minute, resets hard, reloads nginx if the conf changed. Logs: `journalctl -u seapot-menu-autodeploy`.
- Public access: Cloudflare Tunnel `seapot-menu-sj` (locally managed — routes live in `/etc/cloudflared/config.yml` on CT 202, not the dashboard). Catch-all `http_status:404` must stay last.

## History
- Before this repo, deploys were manual `scp` to `root@10.0.0.177:/var/www/html/` (CT 202's IP). `setup.sh` backs that copy up to `/root/menu-backup-<date>`; don't deploy that way anymore.
- The old separate `/branden/index.html` (old prices/layout) was replaced by the `PICKS` overlay.

## Gotchas
- nginx sends `Cache-Control: no-cache, must-revalidate` so pushes show up right away (Cloudflare once served a stale menu). Still stale → Cloudflare → Caching → Purge Everything.
- cloudflared hits nginx via `localhost` → **IPv6 `::1`**. Every server block needs `listen [::]:80;` or requests fall through to the default site (looks like "every hostname shows the menu").
- `body{zoom:.5}` is intentional in the current design — don't "fix" it without asking.
