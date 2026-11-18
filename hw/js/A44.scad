
$fn = 96;

// Button cap
cap_diameter = 8.0;
cap_height = 4.0;
edge_radius = 0.3;

// Underside geometry (estimated)
recess_diameter = 6.0;
recess_depth = 3.0;

// Four retaining features
stem_outer = 2.4;
stem_inner = 2.1;
stem_width = 1.3;
stem_height = 3.0;

module cap_body() {
    R = cap_diameter / 2;
    r = edge_radius;

    // Revolve a profile with a rounded top corner
    rotate_extrude(convexity = 10)
        polygon(points = concat(
            [
                [0, 0],
                [R, 0],
                [R, cap_height-r]
            ],
            [
                for (a = [0:5:90])
                    [R-r + r*cos(a),
                     cap_height-r + r*sin(a)]
            ],
            [
                [0, cap_height]
            ]
        ));
}

module retaining_features() {
    // Four ribs surrounding the central opening
    for (a = [0:90:270]) {
        rotate([0, 0, a])
            translate([
                (stem_inner + stem_outer)/4,
                0,
                0
            ])
                cube([
                    (stem_outer-stem_inner)/2,
                    stem_width,
                    stem_height
                ], center=true);
    }
}

module button_cap() {
    difference() {
        cap_body();

        // Hollow underside
        cylinder(
            d = recess_diameter,
            h = recess_depth,
            center = false
        );
    }

    retaining_features();
}

button_cap();
