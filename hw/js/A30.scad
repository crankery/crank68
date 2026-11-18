
$fn = 96;

// Small Start / Select button cap

cap_diameter = 4.6;
cap_height = 5.5;
edge_radius = 0.15;

socket_size = 2.1;
socket_depth = 3.5;

split_width = 0.5;
split_height = 3.1;

module mounting_socket() {
    // Square actuator opening
    translate([
        -socket_size/2,
        -socket_size/2,
        -0.01
    ])
        cube([
            socket_size,
            socket_size,
            socket_depth + 0.01
        ]);

    // Slit through both sides of the cap
    translate([
        -cap_diameter/2 - 0.1,
        -split_width/2,
        -0.01
    ])
        cube([
            cap_diameter + 0.2,
            split_width,
            split_height + 0.01
        ]);
}

module cap_body() {
    R = cap_diameter / 2;
    r = edge_radius;

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

module cross_socket() {
    union() {
        translate([0, 0, socket_depth/2])
            cube([
                socket_width,
                slot_width,
                socket_depth
            ], center = true);

        translate([0, 0, socket_depth/2])
            cube([
                slot_width,
                socket_width,
                socket_depth
            ], center = true);
    }
}

module button_cap() {
    difference() {
        cap_body();
        mounting_socket();
    }
}

button_cap();
