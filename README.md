# Seapot Menu

QR menu for Seapot Korean BBQ & Hot Pot — **https://menu.adsuaracloud.com**
Staff bar guide lives in [`jerrekt/seapot-bar`](https://github.com/jerrekt/seapot-bar).

## Files
- `site/index.html` — the menu (single self-contained page)
- `/branden` — same page with Branden's Picks tagged (`PICKS` list in the script; preview with `?picks=1`)
- `deploy/` — nginx config, systemd units, setup + auto-deploy scripts
- `prints/chip/` — 45mm QR chip (STL + build script). Pause at Z=2.4mm, black → white.
- `prints/plaques/` — older QR plaques/stands (OpenSCAD + STL)

## Time-based menu
Picks lunch vs dinner from Pacific time (not the phone's timezone):
- Mon–Fri 11:00am–4:00pm → Lunch + Silver + Gold
- Mon–Fri 4:00pm–11:30pm, Sat–Sun all day → Silver + Gold only
- Outside 11am–11:30pm → "Currently closed" banner, Silver/Gold shown
- Change hours via `LUNCH_START`, `LUNCH_END`, `OPEN`, `CLOSE` near the bottom
- Preview: `?mode=lunch` or `?mode=dinner`

No holiday handling yet — lunch card still shows on weekday holidays.

## Deploy
Hosted on SJ Proxmox CT 202 `menu-server` (`10.0.0.177`), nginx, public via Cloudflare Tunnel `seapot-menu-sj`.
A systemd timer pulls `main` every minute and applies changes — **push to deploy** (no more scp).
nginx sends `Cache-Control: no-cache` so updates show immediately.

First-time server setup: `deploy/setup.sh` (backs up the old `/var/www/html` first).

## Open items
- Board vs site mismatches: fresh juice $3.00 on board vs $3.50 on site; Beer Bomb adds Soju; Maru-Hi ($5.99) missing
- Holiday handling for the lunch card
- Real restaurant photos
