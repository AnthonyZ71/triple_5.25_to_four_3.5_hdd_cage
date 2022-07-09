
use <snap-pins.scad>;

SBC = "rockpro64";
PART = "tower-test"; // ["tower", "tower_face", "cage", "rail", "fan_shroud", "fan_mounting_pin", "sbc_mount", "test"]
// Select the grill style for the fan shroud.  Use custom and replace the fan_cover_custom.stl with your custom grill (see README.md for more details.)  Select none for an empty hole with an externally mounted grill cover.
grill_style = "fan_cover_crosshex.stl"; // [fan_cover_crosshair.stl:crosshair,fan_cover_crosshex.stl:crosshex,fan_cover_grid.stl:grid,fan_cover_teardrop.stl:teardrop,fan_cover_web.stl:web,fan_cover_custom.stl:custom,fan_cover_none.stl:none]

include_fan_mount = true;

fan_grill_cover_height = 2;
shroud_w = 120;
shroud_l = 120;
shroud_h = 29;
shroud_inset = 11;

// How much tolerance to add to the prints.  This primarily impacts the rail channels, but also has some other impacts such as the pins on the rail that plug into the hard drive.
tolerance = 0.2;

bay_h = 41.3 + tolerance;
bay_w = 146.1 + tolerance;

drive_h = 29 + tolerance; // 41 + tolerance;
drive_w = 146 + tolerance;
drive_l = 165 + tolerance;

// See https://toshiba.semicon-storage.com/us/storage/support/faq/storage-holes.html
hdd_a1  =  26.10 + 0;
hdd_a2  = 147.00 + 0;
hdd_a3  = 101.60 + 0;
hdd_a4  =  95.25 + 0;
hdd_a5  =   3.18 + 0;
hdd_a6  =  44.45 + 0;
hdd_a7  =  41.28 + 0;
hdd_a8  =  28.50 + 0;
hdd_a9  = 101.60 + 0;
hdd_a10 =   6.35 + 0;
hdd_a13 =  76.20 + 0;

// See SFF-8551
cd_a1  =  41.53 + 0;
cd_a2  =  42.30 + 0;
cd_a3  = 148.00 + 0;
cd_a4  = 202.80 + 0;
cd_a5  = 146.05 + 0;
cd_a6  = 139.70 + 0;
cd_a7  =   3.18 + 0;
cd_a8  =  79.25 + 0;
cd_a9  =  47.40 + 0;
cd_a10 =  47.40 + 0;
cd_a11 =  79.25 + 0;
cd_a13 =  10.00 + 0;
cd_a14 =  21.84 + 0;
cd_a16 =   6.50 + 0;
cd_a17 =   5.00 + 0;

hdd_h = hdd_a1 + tolerance;
hdd_w = hdd_a3 + tolerance;
hdd_l = hdd_a2 + tolerance;

cage_h = 125.75 + 0;
cage_w = 145 + 0; // 146;
cage_l = hdd_a2 - hdd_a7 + 20; //cd_a10 + cd_a11 + 10;

total_rail_height = 8 + 0;

pin_d = 2.7 - tolerance; //.1140 * 25.4;
main_rail_offset = hdd_a2 - hdd_a8 - hdd_a9 - pin_d/2;
main_rail_length = 4 * 25.4;

echo("old", cd_a10 + cd_a11 + 10);
echo("new", hdd_a2 - hdd_a7 + 20);

spacing_w = 4 + 0;

// pin connector settings.
snap_pin_pointed = 1;
snap_pin_fins = 1;
snap_pin_preload = 0.2;
snap_pin_clearance = 0.2;
snap_pin_printable = 1;
snap_pin_shadow_socket = 1;
snap_pin_spacing = 20;
snap_pin_cylinder_thickness = 2;

snap_pin_length = 6;
snap_pin_diameter = 3.2;
snap_pin_snap = 0.4;
snap_pin_snapDepth = 1.2;
snap_pin_thickness = 1.0;

$fn=$preview ? 18 : 120;

standoff_h = 6;
standoff_d = 9;
standoff_hole_d = 5.45 - tolerance;

// SBC cavity settings
sbc_none      = [[0, 0, 0], [], [ 85 ]];
sbc_rockpro64 = [
    [80, 128, 20],   // x, y (side w/ no ports), z (clearance),
    [ // stand-off locations
        [4.5,       4.5], 
        [80 - 4.5,  4.5],
        [4.5,       128  - 4.5],
        [80 - 4.5,  128  - 4.5]
    ],
    [
      63 // minimum cavity height
    ]
];
sbc =
    SBC=="rockpro64" ? sbc_rockpro64 :
    sbc_none
    ;
sbc_plate_h = 2;
sbc_cavity_h = tolerance + sbc_plate_h + standoff_h + sbc[2][0] + tolerance;

echo("sbc cavity height", sbc_cavity_h);

tower_h = max(cage_h, sbc[0][0] + (spacing_w + tolerance) * 2);
tower_w = cage_w + sbc_cavity_h + spacing_w;
tower_l = cage_l;

lip_height       = 12;
lip_thickness    = 1.2;
lip_screw_hole_d = 3;
lip_screw_hole_z = 5;
lip_screw_hole_inset = 20;
lip_screws = [
    [ cage_w/2 - 31,  tower_h/2],
    [ cage_w/2 - 31, -tower_h/2],
    [-cage_w/2 + 45.5,  tower_h/2],
    [-cage_w/2 + 45.5, -tower_h/2]
];

module vertical_hdd(l = hdd_l) {
    translate([hdd_h, 0, 0]) {
        rotate([0, -90, 0]) {
            cube([hdd_w, l, hdd_h]);
            translate([-total_rail_height + 0.01, 0, hdd_a10])
                rotate([0, 90, 0])
                    rail(false);
            translate([hdd_w + total_rail_height - 0.01, 0, hdd_a10])
                rotate([0, -90, 0])
                    rail(false);
        }
    }
}

module caged_hdds() {
    hdds_area = cage_w - spacing_w * 2;
    hdd_area = hdds_area / 4;
    for(i = [0 : 1 : 3 ]) {
        translate([i * hdd_area + spacing_w, -1, (cage_h - hdd_w) / 2])
            vertical_hdd(hdd_l + 2);
    }
}

module rail_spacing() {
    rail = 4;
    rail_s = 3;
    offset = sqrt(2 * rail * rail)/2 - rail_s / 2;

    translate([0, 1, -rail_s/2])
        rotate([0, 45, 0])
            cube([rail, cage_l*2, rail], center=true);
    translate([-offset, 1, 0])
        cube([rail_s, cage_l * 2, rail_s], center=true);
    translate([offset, 1, 0])
        cube([rail_s, cage_l * 2, rail_s], center=true);
    translate([0, 1, rail_s/2])
        rotate([0, 45, 0])
            cube([rail, cage_l*2, rail], center=true);
}

module fan_mounting_sockets(w = cage_w, h = cage_h) {
    center_w = w/2;
    center_h = h/2;
    corner_w = w/2 - 4;
    corner_h = h/2 - 8;
    snap_pin_radius = snap_pin_diameter / 2;
    cylinder_r = snap_pin_radius + snap_pin_snap + snap_pin_cylinder_thickness;
    cylnder_h = snap_pin_length + snap_pin_cylinder_thickness;
    for(w = [-1 : 2 : 1]) {
        x = center_w + corner_w * w;
        for (h = [-1 : 2 : 1]) {
            z = center_h + corner_h * h;
            translate([x, 0, z])
                rotate([-90, 0, 0])
                    showSocket(radius = snap_pin_radius,
                                length = snap_pin_length,
                                snapDepth = snap_pin_snapDepth,
                                snap = snap_pin_snap,
                                thickness = snap_pin_thickness,
                                pointed = snap_pin_pointed,
                                fixed = 0,
                                fins = false,
                                printable = false,
                                cylinderRadius = cylinder_r,
                                cylinderHeight = cylnder_h);
        }
    }
}

module sbc_mount() {
    bridge_w = hdd_w + total_rail_height * 2;
    bridge_l = spacing_w * 7;
    
    plate_w = sbc[0][0];
    plate_l = sbc[0][1];
    plate_h = sbc_plate_h;

    
    // Bridge plate
    for (bridge_y = [main_rail_offset + main_rail_length - (bridge_l + spacing_w *2),
                     spacing_w * 6.75]) {       
        translate([0, bridge_y, 0]) {
            cube([bridge_w, bridge_l, plate_h]);
        }
    }
        
    // SBC plate
    translate([(bridge_w - plate_w) / 2, 0, 0]) {
        cube([plate_w, plate_l, plate_h]);
        
        // SBC stand-offs go here
        for (standoff = sbc[1]) {
            translate([standoff[0], standoff[1], (standoff_h + plate_h) / 2]) {
                difference() {
                    cylinder(h = standoff_h + plate_h, d = standoff_d, center = true);
                    
                    translate([0, 0, plate_h])
                        cylinder(h = standoff_h + plate_h, d = standoff_hole_d, center = true);
                }
            }
        }
    }
    
    // Rails to connect to tower
    translate([0, 0, total_rail_height*3/4 + 0.15])
        rotate([0, 90, 0])
            rail(with_pin = false);
    translate([bridge_w, 0, total_rail_height*3/4 + 0.15])
        rotate([0, -90, 0])
            rail(with_pin = false);
}

module tower() {
    cut = 7;
    cage_x = tower_w - cage_w;
    cage_z = (tower_h - cage_h) / 2;

    difference() {
        cube([tower_w, tower_l, tower_h]);
        
        // cut off harsh corners
        translate([0, cut, 0])
            rotate([0, 45, 0])
                cube([cut, tower_l*2, cut], center=true);
        translate([tower_w, cut, 0])
            rotate([0, 45, 0])
                cube([cut, tower_l*2, cut], center=true);
        translate([0, cut, tower_h])
            rotate([0, 45, 0])
                cube([cut, tower_l*2, cut], center=true);
        translate([tower_w, cut, tower_h])
            rotate([0, 45, 0])
                cube([cut, tower_w*2, cut], center=true);
        
        ///////////////////////
        // SECTION: SBC mount
        ///////////////////////

        // cut out center cavity 
        translate([cage_x/2 + spacing_w/2, tower_l/2, tower_h/2])
            cube([cage_x - spacing_w, tower_l * 2, hdd_w], center=true);
        
        // cut out sbc mount area
        translate([cage_x, -1, (cage_h - hdd_w) / 2]) {
            translate([-hdd_h, 0, 0])
                vertical_hdd(hdd_l + 2);
            
            translate([-spacing_w, 0, -spacing_w])
                cube([spacing_w, main_rail_offset + main_rail_length, hdd_w + spacing_w * 2]);
        }
        
        ///////////////////////
        // SECTION: Drive cage
        ///////////////////////
        translate([cage_x, 0, cage_z]) {

            // cut outs relative to the center of the cage
            translate([cage_w/2, cage_l/2, cage_h/2]) {
                // center cavity
                cube([hdd_h * 4 + spacing_w*7, cage_l * 2, hdd_w], center=true);
                
                // lip around the sides.
                for (lip = [1, -1]) {
                    h = lip_height + tolerance/2;
                    t = lip_thickness + tolerance/2;
                    translate([0, (h - tower_l) / 2, lip * (tower_h - t) / 2])
                        cube([cage_w + tolerance * 2, h + 0.001, t + 0.004], center=true);
                }
            
                // holes for heat-set inserts
                rotate([90, 0, 0])
                    for (screw = lip_screws)
                        translate([screw[0], screw[1], tower_h / 2 - lip_screw_hole_z - tolerance])
                            rotate([90, 0, 0])
                                cylinder(h = (standoff_h + 0.5) * 2, d = standoff_hole_d, center = true);
            }
            
            // cut out the hdd vertical spacing
            translate([spacing_w, 0, 0])
                caged_hdds();
            
            // cut out routing for fan power cable.
            center_w = cage_w/2;
            center_h = cage_h/2;
            corner_w = (cage_w - spacing_w*4)/2 - 1;
            corner_h = hdd_w/2 - 1;
            for(w = [-1 : 2 : -1]) {
                x = center_w + corner_w * w;
                for(h = [-1 : 2 : 1]) {
                    z = center_h + corner_h * h;
                    translate([x, cage_l/2, z])
                        rotate([90, 0, 0])
                            cylinder(cage_l + 2, r=3, center=true);
                }
            }
        }
    }
}

module cage() {
    cut = 7;
    difference() {
        // main area
        cube([cage_w, cage_l, cage_h]);
        // cut off harsh corners
        translate([0, cut, 0])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([cage_w, cut, 0])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([0, cut, cage_h])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        translate([cage_w, cut, cage_h])
            rotate([0, 45, 0])
                cube([cut, cage_l*2, cut], center=true);
        // cut out socket for mounting pin for fan
        if (include_fan_mount) {
            fan_mounting_sockets();
        }
        // cut out space for bay rails
        translate([cage_w, 0, cage_h*1/3 + 1.5])
            rail_spacing();
        translate([cage_w, 0, cage_h*2/3 + 1.5])
            rail_spacing();
        translate([0, 0, cage_h*1/3 + 1.5])
            rail_spacing();
        translate([0, 0, cage_h*2/3 + 1.5])
            rail_spacing();
        // cut out center stuff
        translate([cage_w/2, cage_l/2, cage_h/2])
            cube([hdd_h * 4 + spacing_w*7, cage_l * 2, hdd_w], center=true);
        // cut out the hdd vertical spacing
        translate([spacing_w, 0, 0])
            caged_hdds();
        // cut out 5.25" drive mounting holes.
        mounting_d = 3.0;
        for(drive = [0 : 1 : 2]) {
            drive_offset = drive * (cd_a2 + .5);
            for(set = [0 : 1 : 1]) {
                set_offset = cage_l - shroud_inset - (cd_a11 * set); // cd_a10 + cd_a11 * set;
                for(mount = [0 : 1 : 1]) {
                    mount_offset = mount ? cd_a13 : cd_a14;
                    translate([-10, set_offset, drive_offset + mount_offset]) {
                        rotate([0, 90, 0]) {
                            cylinder(20, d=mounting_d);
                        }
                    }
                    translate([-10 + cage_w, set_offset, drive_offset + mount_offset]) {
                        rotate([0, 90, 0]) {
                            cylinder(20, d=mounting_d);
                        }
                    }
                }
            }
        }
        // cut out routing for fan power cable.
        center_w = cage_w/2;
        center_h = cage_h/2;
        corner_w = (cage_w - spacing_w*4)/2 - 1;
        corner_h = hdd_w/2 - 1;
//        for(w = [-1 : 2 : 1]) {
// No space on the other side for cable routing.
        for(w = [-1 : 2 : -1]) {
            x = center_w + corner_w * w;
            for(h = [-1 : 2 : 1]) {
                z = center_h + corner_h * h;
                translate([x, cage_l/2, z])
                    rotate([90, 0, 0])
                        cylinder(cage_l + 2, r=3, center=true);
            }
        }
    }
}

module pin(pin_diameter, pin_length) {
    point = pin_diameter / 2;
    body = pin_length - point;

    rotate([0, 90, 0]) {
        translate([0, 0, -point/2]) {
            cylinder(h = body, d=pin_diameter, center=true);
            translate([0, 0, body/2])
                sphere(d = pin_diameter);
        }
    }
}

module clip(height, length, width) {
    angle = 16;

    translate([-width/2, 0, -height]) {
        difference() {
            rotate([angle, 0, 0])
                cube([width, length, height]);
            translate([-1, -2, height])
                cube([width * 2, length * 2, height + 2]);
            translate([-1, -length + 0.01, -0.01])
                cube([width * 2, length, height + 2]);
        }
    }
}

module handle(length, width, height, rail_height, positive=true) {
    t = tolerance;

    s1_l = length / 2;
    s2_angle = 40;
    // math to make the length of section 2 be half the
    // length of section 1.
    s2_l = (s1_l / 2) / cos(s2_angle);
    s2_x = s1_l;
    s3_l = (s1_l / 2);
    s3_z = (s1_l / 2) * tan(s2_angle);
    extension = s2_angle / 90 * height;

    clip_h = 1.5;
    clip_l = 6;
    clip_w = width / 3;

    if (positive == true) {
        translate([-width/2, s1_l, 0])
            cube([width, s1_l, height]);
        translate([0, s1_l + 1, 0.01])
            clip(clip_h, clip_l, clip_w);
        translate([width/2, s1_l, 0])
            rotate([s2_angle, 0, 180])
                cube([width, s2_l + extension, height]);
        translate([-width/2, 0, s3_z])
            cube([width, s3_l + extension, height]);
        translate([-width/2, 0, s3_z - 2 + height])
            cube([width, 1, height]);
    } else {
        trim = width/2+tolerance*2;
        translate([-clip_w/2, s1_l + .4, -9])
            cube([clip_w + .4, clip_l/2 + .4, 10]);
        translate([-width/2, 0, 0])
            difference() {
                cube([width, length + 8, rail_height]);
                translate([0, length, rail_height - width/2]) rotate([0, 0, 45])
                    cube([trim*2, trim, trim]);;
                translate([width, length, rail_height - width/2]) rotate([0, 0, 45])
                    cube([trim, trim*2, trim]);
            }
    }
}

module rail(positive=true, with_pin=true) {
    pin_len = 6;
    t = (positive) ? 0 : tolerance * 2;
    top_width = (pin_d > 3) ? pin_d + t: 3 + t;
    top_height=total_rail_height / 3 + t;
    bottom_width= (positive) ? (hdd_a10 - tolerance) * 2 : hdd_a10*2;
    bottom_height=total_rail_height * 2 / 3 + t;
    total_height=top_height + bottom_height;
    top_y = (top_height + bottom_height)/2;
    mid_y = top_y - top_height;
    bottom_y = -top_y;
        
    //  A_|_B
    //C /   \D
    //E|_____|F
    points = [
        [-top_width/2, top_y], // A
        [top_width/2, top_y], // B
        [bottom_width/2, mid_y], // D
        [bottom_width/2, bottom_y], // F
        [-bottom_width/2, bottom_y], // E
        [-bottom_width/2, mid_y], // C
    ];
    faces = [[0, 1, 2, 3, 4, 5]];

    echo("main_rail_offset = ", main_rail_offset);
    translate([0, main_rail_offset, -bottom_y]) {
        rotate([90, 0, 180]) 
            linear_extrude(main_rail_length + pin_d)
                polygon(points, faces);
    }
    if (positive && with_pin) {
        translate([0, main_rail_offset, total_height + pin_len/2-0.01]) {
            translate([0, pin_d/2, 0])
                rotate([0, -90, 0])
                    pin(pin_d, pin_len);
            translate([0, main_rail_length + pin_d/2, 0])
                rotate([0, -90, 0])
                    pin(pin_d, pin_len);
        }
    }
    handle(main_rail_offset, bottom_width, 1.5, total_height, positive);
}

module fan_shroud() {
    shroud_t = 4;
    outer_wall = cage_h - 110;

    import(grill_style);
    translate([0, 0, shroud_h/2]) {
        difference() {
            cube([cage_w, cage_h, shroud_h], center=true);
            cube([shroud_w - 0.001, shroud_l - 0.001, shroud_h + 10], center=true);
            translate([0, 0, fan_grill_cover_height - tolerance + 0.001])
                cube([cage_w - outer_wall, shroud_l + tolerance * 2, shroud_h], center=true);
            translate([-cage_w/2, -cage_h/2, shroud_h/2])
                rotate([-90, 0, 0])
                    fan_mounting_sockets();

            // Cut out finger grips to pull the shroud off
//            translate([-cage_w/2 - 0.01, 0, -shroud_h/2 + 2])
//                fan_shroud_grip();
//            translate([cage_w/2 + 0.01, 0, -shroud_h/2 + 2])
//                rotate([0, 0, 180])
//                    fan_shroud_grip();

            // Cut out space for the bay rails
            rail_spacing_z = cage_l - shroud_h/2 + shroud_inset - 2;
            translate([cage_w/2, cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([cage_w/2, -cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([-cage_w/2, cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();
            translate([-cage_w/2, -cage_h/6 - 1.5, rail_spacing_z])
                rotate([90, 0, 0])
                    rail_spacing();

            // cut off harsh corners
            cut=7;
            translate([cage_w/2, cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([cage_w/2, -cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([-cage_w/2, cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);
            translate([-cage_w/2, -cage_h/2, shroud_inset - 2])
                rotate([0, 0, 45])
                    cube([cut, cut, shroud_h], center=true);

        }
        translate([-cage_w/2 + .1, 0, -shroud_h/2 + 2])
            fan_shroud_texture(2);
        translate([cage_w/2 - .1, 0, -shroud_h/2 + 2])
            fan_shroud_texture(1.75);
    }
}

module fan_mounting_pin() {
    showPin(radius = snap_pin_diameter/2,
            length = snap_pin_length,
            snapDepth = snap_pin_snapDepth,
            snap = snap_pin_snap,
            thickness = snap_pin_thickness,
            clearance = snap_pin_clearance,
            preload = snap_pin_preload,
            pointed = snap_pin_pointed,
            printable = snap_pin_printable,
            shadowSocket = snap_pin_shadow_socket);
}

module ridge_line(diameter, length) {
    end_offset = (length - diameter) / 2;
    rotate([90, 0, 0]) {
        translate([0, 0, end_offset]) sphere(d = diameter);
        cylinder(h = length - diameter, d = diameter, center=true);
        translate([0, 0, -end_offset]) sphere(d = diameter);
    }
}

// https://www.dummies.com/article/academics-the-arts/math/calculus/how-to-graph-an-ellipse-190940
module fan_shroud_texture(diameter) {
    a = 25.4;
    b = a / 2;
    a2 = a * a;
    b2 = b * b;
    // x^2 / a^2 + y^2 / b^2 = 1
    for(y = [0 : b/5 : b - .1]) {
        x = sqrt((1 - (y * y) / b2) * a2);
        echo ("y = ", y, "  ;  x = ", x);
        translate([0, 0, y]) ridge_line(diameter, x);
    }
}

module fan_shroud_grip() {
    grip_w = 25.4;
    grip_d = 4;
    x_scale = grip_d / 25.4;
    z_scale = (grip_w * 1.5) / grip_w;

    scale([x_scale, 1, z_scale]) {
        difference() {
            sphere(d=grip_w);
            translate([0, 0, -grip_w/2]) cube(grip_w, center=true);
            translate([-grip_w/2, 0, 0]) cube(grip_w, center=true);
        }
    }

}

module tower_face() {
    shroud_t = 4;
    
    height = shroud_h + lip_height;
    
    outer_wall = tower_h - 110;

    import(grill_style);
    translate([0, 0, height/2]) {
        difference() {
            cube([cage_w, tower_h, height], center=true);
            
            // lip around the sides.
            translate([0, 0, shroud_h / 2])
                cube([cage_w + 1, tower_h - lip_thickness * 2, lip_height + tolerance + 0.001], center=true);
            
            // holes for screws
            for (screw = lip_screws)
                translate([screw[0], screw[1], height/2 - lip_height + lip_screw_hole_z])
                    rotate([90, 0, 0])
                        cylinder(h = lip_thickness * 4, d = lip_screw_hole_d, center = true);
            
            // cavity for fan
            cube([shroud_w - 0.001, shroud_l - 0.001, height + 10], center=true);
            translate([0, 0, fan_grill_cover_height - tolerance + 0.001])
                cube([cage_w - outer_wall, shroud_l, height], center=true);

            // cut off harsh corners
            cut=7;
            translate([cage_w/2, tower_h/2, 0])
                rotate([0, 0, 45])
                    cube([cut, cut, height + 1], center=true);
            translate([cage_w/2, -tower_h/2, 0])
                rotate([0, 0, 45])
                    cube([cut, cut, height + 1], center=true);
        }
    }
}

if (PART == "cage") {
    translate([0, 0, cage_l])
        rotate([-90, 0, 0])
            cage();
} else if (PART == "tower") {
    translate([0, 0, tower_l])
        rotate([-90, 0, 0])
            tower();
} else if (PART == "rail") {
    translate([0, 0, total_rail_height*3/4])
        rotate([0, 90, 0])
            rail();
} else if (PART == "sbc_mount") {
    sbc_mount();
} else if (PART == "fan_shroud") {
    fan_shroud();
} else if (PART == "tower_face") {
    tower_face();
} else if (PART == "fan_mounting_pin") {
    fan_mounting_pin();
} else if (PART == "test") {
    translate([-cage_w/2 + 10, 0, cage_l]) {
        difference() {
            rotate([-90, 0, 0]) {
                cage();
            }
            translate([-hdd_h*1.25-5, -5, -cage_l-10])
                cube([cage_w+10, cage_h+10, cage_l+50]);
            translate([10, -10, -cage_l-10])
                cube([cage_w+10, cage_h - total_rail_height/2, cage_l + 50]);
        }
    }
    cage_face_h = 5;
    translate([0, cage_w, cage_face_h]) {
        rotate([0, 0, -90]){
            difference() {
                rotate([-90, 0, 0]) {
                    cage();
                }
                translate([-10, -10, -cage_l - 1]) {
                    cube([cage_w+20, cage_h+20, cage_l - cage_face_h + 1]);
                }
            }
        }
    }
    translate([cage_w / 2 - 10, cage_w * 1.6, -(shroud_h - 9)]) {
        rotate([0, 0, 90]) {
            difference() {
                fan_shroud();
                translate([-10, 5, (shroud_h - 10)/2])
                    cube([cage_w + 10, cage_h + 20, shroud_h - 8], center=true);
                translate([10, 0, shroud_h / 2])
                    cube([cage_w-10, cage_h+20, shroud_h + 5], center=true);
            }
        }
    }
    translate([20, 15, total_rail_height*3/4]) {
        rotate([0, 90, 0]) {
            rail();
        }
    }
    translate([40, 25, 0]) {
        fan_mounting_pin();
    }
} else {
    translate([20, 0, tower_w + 20]) rotate([0, 90, 0]) {
            
        translate([20, 0, 0])
            tower();

        translate([cage_w/2 + tower_w - cage_w + 20, -shroud_h, cage_h/2])
            rotate([-90, 0, 0])
                tower_face();
        
        translate([tower_w - cage_w + 20, -20, 4 + tolerance])
            rotate([0, -90, 0])
                sbc_mount();
    }
    
    translate([0, 0, 30])
        handle(15.525, 15, 1.5, total_rail_height, true);
    translate([-20, 0, 30])
        translate([-total_rail_height, 0, 0])
            handle(15.525, 15, 1.5, total_rail_height, false);

    translate([0, 0, total_rail_height*3/4])
        rotate([0, 90, 0])
            rail();
    translate([-20, 0, hdd_a5 + (.1380 * 25.4)/2])
        rotate([0, 90, 0])
            rail(false);
}
