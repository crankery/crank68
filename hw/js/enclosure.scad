
$fn = 96;

// C68 Mini Gamepad Enclosure

// External dimensions
length = 80;
width = 50;
height = 20;

// Construction
wall = 1.0;
corner_radius = 3.0;
lid_thickness = 1.0;

// Button caps
large_cap_d = 8.0;
small_cap_d = 4.6;
button_clearance = 0.4; // Added to diameter

// Display options
show_lid = true;
show_body = true;

// Button coordinates relative to enclosure's
// top-left corner (80 x 50 mm).
// [X, Y]
large_buttons = [
    [18.8, 22.5], // Up
    [26.3, 30.0], // Right
    [18.8, 37.5], // Down
    [11.3, 30.0], // Left
    [53.7, 30.0], // A
    [68.7, 30.0]  // B
];

small_buttons = [
    [33.8, 10.0], // Select
    [46.2, 10.0]  // Start
];

mounting_holes = [
    [-34.55,  19.55],
    [ 34.55,  19.55],
    [-34.55, -19.55],
    [ 34.55, -19.55]
];

mounting_hole_d = 2.7; // M2.5 clearance

module mounting_hole_cuts() {
    for (p = mounting_holes)
        translate([
            p[0],
            p[1],
            height - lid_thickness - 0.1
        ])
            cylinder(
                d = mounting_hole_d,
                h = lid_thickness + 0.2
            );
}

// Rounded rectangle, extruded vertically
module rounded_box(l, w, h, r) {
    linear_extrude(height = h)
        offset(r = r)
            square(
                [l-2*r, w-2*r],
                center = true
            );
}

// Main enclosure
module enclosure_body() {
    difference() {
        rounded_box(
            length,
            width,
            height-lid_thickness,
            corner_radius
        );

        translate([0, 0, wall])
            rounded_box(
                length-2*wall,
                width-2*wall,
                height,
                max(0.01, corner_radius-wall)
            );
    }
}

// Drill holes in lid
module button_holes() {
    // Large buttons
    for (p = large_buttons) {
        translate([
            p[0]-length/2,
            width/2-p[1],
            height-lid_thickness-0.1
        ])
            cylinder(
                d = large_cap_d + button_clearance,
                h = lid_thickness + 0.2
            );
    }

    // Start / Select
    for (p = small_buttons) {
        translate([
            p[0]-length/2,
            width/2-p[1],
            height-lid_thickness-0.1
        ])
            cylinder(
                d = small_cap_d + button_clearance,
                h = lid_thickness + 0.2
            );
    }
}

// Lid with holes
module enclosure_lid() {
    difference() {
        translate([0, 0, height-lid_thickness])
            rounded_box(
                length,
                width,
                lid_thickness,
                corner_radius
            );

        button_holes();
        mounting_hole_cuts();
    }
}

// Assembly
if (show_body)
    color("silver")
        enclosure_body();

if (show_lid)
    color("lightgray", 0.75)
        enclosure_lid();
