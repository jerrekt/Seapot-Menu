// ============================================================
// SEAPOT Table Menu Sign — QR Code Plaque (Branden's Picks)
// Encodes: https://menu.adsuaracloud.com/branden
// ============================================================
// HOW TO USE:
// 1. Install OpenSCAD (free): https://openscad.org/downloads.html
// 2. Open this file in OpenSCAD
// 3. Press F6 (Render), then F7 or File > Export > Export as STL
// 4. Open the STL in Bambu Studio and slice/print
//
// TWO-COLOR PRINT (raised parts white, base black) — no AMS needed:
// - Load BLACK filament, print the base plate (plate_t = 3mm)
// - At the layer where Z = 3mm (e.g. layer 15 at 0.2mm layer height),
//   pause the print (Bambu Studio: right-click the layer in preview ->
//   "Add pause" / filament change at that layer)
// - Swap to WHITE filament, resume — all raised QR/text geometry
//   starts exactly at Z=3mm, so this gives a clean single color split
// - 0.2mm layer height, no supports needed
// ============================================================

// ---------- PARAMETERS (adjust if needed) ----------
plate_w   = 100;   // plate width (mm)
plate_h   = 150;   // plate height (mm)
plate_t   = 3;     // base plate thickness (mm)
raise_h   = 1.5;   // height of raised QR/text (mm)

qr_size   = 80;    // QR code printed size (mm) -- square
qr_y_pos  = 37;    // distance from bottom edge to bottom of QR code

corner_r  = 4;     // corner rounding radius

// ---------- QR MATRIX (29x29, generated from menu URL) ----------
qr_matrix = [
  [1,1,1,1,1,1,1,0,1,1,1,1,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1],
  [1,0,0,0,0,0,1,0,0,0,1,1,0,0,0,0,1,1,0,1,1,0,1,0,0,0,0,0,1],
  [1,0,1,1,1,0,1,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,1,0,1,1,1,0,1],
  [1,0,1,1,1,0,1,0,1,1,0,1,0,0,0,1,1,0,1,1,0,0,1,0,1,1,1,0,1],
  [1,0,1,1,1,0,1,0,1,0,1,1,0,0,1,1,1,0,0,0,0,0,1,0,1,1,1,0,1],
  [1,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1],
  [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
  [0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0],
  [1,0,0,0,1,0,1,1,1,0,1,0,1,1,0,0,0,1,0,1,1,1,1,1,1,1,0,0,1],
  [0,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1],
  [1,0,0,1,0,1,1,0,0,1,0,1,1,0,0,1,1,1,1,0,1,0,0,0,0,0,0,0,1],
  [1,0,0,1,0,0,0,1,1,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,0,1,1],
  [0,1,0,0,1,0,1,1,0,0,1,1,0,1,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0],
  [0,1,1,1,0,0,0,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1],
  [0,0,1,1,0,0,1,0,0,0,1,0,1,1,1,1,0,0,1,0,0,1,1,1,1,1,1,0,1],
  [1,1,0,0,0,0,0,0,1,0,0,0,0,1,0,1,1,1,0,1,0,0,1,0,1,0,0,1,1],
  [1,1,1,1,1,1,1,0,0,0,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0,1,0],
  [1,0,0,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,0,0,0,1,1,1,1,0,1,1],
  [0,0,0,0,1,0,1,1,0,0,0,1,0,0,0,1,1,0,0,0,1,0,1,0,0,0,1,0,1],
  [0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,1,1,0,0,1,1,0,0,0,0,1,1],
  [1,1,1,1,0,1,1,1,0,0,1,0,1,1,1,0,1,1,0,1,1,1,1,1,1,1,0,0,1],
  [0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,0,1,0,0,0,1],
  [1,1,1,1,1,1,1,0,1,0,0,0,0,1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1],
  [1,0,0,0,0,0,1,0,0,1,1,1,0,1,0,0,1,1,1,1,1,0,0,0,1,0,0,0,1],
  [1,0,1,1,1,0,1,0,1,1,1,0,0,1,0,0,0,1,0,1,1,1,1,1,1,1,0,1,0],
  [1,0,1,1,1,0,1,0,0,1,1,1,0,0,1,1,1,1,1,0,1,1,0,0,0,0,0,0,1],
  [1,0,1,1,1,0,1,0,0,1,0,0,0,1,1,1,0,1,1,1,0,0,0,0,0,1,1,1,1],
  [1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,1,1,1,1,1,0,0,1,0,1,1],
  [1,1,1,1,1,1,1,0,1,1,0,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,0,1,0],
];

qr_dim = len(qr_matrix);              // 29
module_size = qr_size / qr_dim;       // mm per QR pixel

// ---------- BASE PLATE ----------
module base_plate() {
  linear_extrude(height = plate_t)
    offset(r = corner_r)
      offset(delta = -corner_r)
        square([plate_w, plate_h]);
}

// ---------- QR CODE (raised) ----------
module qr_code() {
  qr_x_offset = (plate_w - qr_size) / 2;
  qr_y_offset = qr_y_pos;

  translate([qr_x_offset, qr_y_offset, plate_t])
    for (row = [0:qr_dim-1]) {
      for (col = [0:qr_dim-1]) {
        if (qr_matrix[qr_dim-1-row][col] == 1) {
          translate([col * module_size, row * module_size, 0])
            cube([module_size, module_size, raise_h]);
        }
      }
    }
}

// ---------- TEXT (raised) ----------
module sign_text() {
  // Restaurant name (top)
  translate([plate_w/2, 138, plate_t])
    linear_extrude(height = raise_h)
      text("SEAPOT", size = 14, halign = "center", valign = "center",
           font = "Liberation Sans:style=Bold");

  translate([plate_w/2, 124, plate_t])
    linear_extrude(height = raise_h)
      text("Hot Pot & BBQ", size = 6, halign = "center", valign = "center",
           font = "Liberation Sans");

  // Phone number (below QR)
  translate([plate_w/2, 24, plate_t])
    linear_extrude(height = raise_h)
      text("408-685-2268", size = 6, halign = "center", valign = "center",
           font = "Liberation Sans:style=Bold");

  // WiFi password (bottom)
  translate([plate_w/2, 10, plate_t])
    linear_extrude(height = raise_h)
      text("WiFi 4086852268", size = 6, halign = "center", valign = "center",
           font = "Liberation Sans:style=Bold");

  // Subtle corner marker (differentiates this plaque)
  translate([plate_w - 8, 8, plate_t])
    linear_extrude(height = raise_h)
      circle(d = 4);
}

// ---------- ASSEMBLE ----------
base_plate();
qr_code();
sign_text();
