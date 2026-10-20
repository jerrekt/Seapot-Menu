# Seapot Menu

QR menu for Seapot Korean BBQ & Hot Pot — https://menu.adsuaracloud.com

## Files
- `index.html` — main menu (single self-contained page)
- `branden/index.html` — Branden's Picks (`/branden`). **Old layout, not yet rebuilt on the new menu.**
- `prints/chip/` — 45mm QR chip (STL + build script). Pause at Z=2.4mm, black → white.
- `prints/plaques/` — older QR plaques/stands (OpenSCAD + STL)

## Time-based menu
`index.html` picks lunch vs dinner from Pacific time (not the phone's timezone):
- Mon–Fri 11:00am–4:00pm → Lunch + Silver + Gold
- Mon–Fri 4:00pm–11:30pm, Sat–Sun all day → Silver + Gold only
- Outside 11am–11:30pm → "Currently closed" banner, Silver/Gold shown
- Change hours via `LUNCH_START`, `LUNCH_END`, `OPEN`, `CLOSE` near the bottom
- Preview: `?mode=lunch` or `?mode=dinner`

No holiday handling yet — lunch card still shows on weekday holidays.

## Deploy (current)
```
scp index.html root@10.0.0.177:/var/www/html/index.html
```
Then purge Cloudflare cache, or add `add_header Cache-Control "no-cache, must-revalidate";` to the nginx `location /` block so updates show immediately.

## Open items
- Rebuild `branden/` on the new layout
- Board vs site mismatches: fresh juice $3.00 on board vs $3.50 on site; Beer Bomb adds Soju; Maru-Hi ($5.99) missing
- Drink menu guide (planned)
- Real restaurant photos
