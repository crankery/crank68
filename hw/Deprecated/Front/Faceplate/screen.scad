$fn = 32;

panel_w = 118.0;
panel_h = 89.0;
panel_d = 6.0;

bezel_w = 5;
overall_d = 8;

insert_hole_d = 3.5;

bighole_d =  (panel_w - bezel_w / 4) / 5;

difference() {
    cube([panel_w+bezel_w*2, panel_h+bezel_w*2, overall_d]);
    translate([bezel_w, bezel_w, -0.1])
      cube([panel_w, panel_h, panel_d]);
  
  translate([2.5-1.75, bezel_w/2 + insert_hole_d/2, -0.1])
    cylinder(h = overall_d + 1, r = insert_hole_d / 2, center = true);
  
  translate([panel_w  + bezel_w + insert_hole_d/2,(bezel_w/2 + insert_hole_d)/2, -0.1])
    cylinder(h = overall_d + 1, r = insert_hole_d / 2);  
  
  // save some plastic...
  translate([bezel_w * 2 + bighole_d / 2, bezel_w * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 2 + bighole_d / 2, bezel_w * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 3 + bighole_d +  bighole_d / 2, bezel_w * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 4 + bighole_d* 2 +  bighole_d / 2, bezel_w * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 5 + bighole_d* 3 +  bighole_d / 2, bezel_w * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);
    
  translate([bezel_w * 2 + bighole_d / 2, bezel_w * 3 + bighole_d + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 3 + bighole_d +  bighole_d / 2, bezel_w * 3 + bighole_d + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 4 + bighole_d* 2 +  bighole_d / 2, bezel_w * 3 + bighole_d + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 5 + bighole_d* 3 +  bighole_d / 2, bezel_w * 3 + bighole_d + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);
    
  translate([bezel_w * 2 + bighole_d / 2, bezel_w * 4 + bighole_d * 2 + bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 3 + bighole_d +  bighole_d / 2, bezel_w * 4 + bighole_d * 2+ bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 4 + bighole_d* 2 +  bighole_d / 2, bezel_w * 4 + bighole_d * 2+ bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);

  translate([bezel_w * 5 + bighole_d* 3 +  bighole_d / 2, bezel_w * 4 + bighole_d * 2+ bighole_d / 2, 0.1])
    cylinder(h = 10, , r = bighole_d / 2);
}
