// Simple Insert Box for Drawer Container
// All dimensions in mm, based on multiples of 8mm

/* [Printer Settings] */
// Nozzle diameter in mm
nozzle_diameter = 0.6; // [0.2, 0.4, 0.6, 0.8]

/* [Container Dimensions] */
// Width of outer container in grid units (1 unit = 8mm)
outer_width_units = 10; // [1:50]

// Depth of outer container in grid units (1 unit = 8mm)
outer_depth_units = 15; // [1:50]

// Height of outer container in grid units (1 unit = 8mm)
outer_height_units = 6; // [1:20]

// Wall thickness of outer container in mm
outer_wall_thickness = 2.4; // [1.6:0.8:4.0]

// Floor thickness of outer container in mm
outer_floor_thickness = 2.4; // [1.6:0.8:4.0]

/* [Insert Box Dimensions] */
// Wall thickness of insert in mm
insert_wall_thickness = 1.2; // [0.8:0.4:2.4]

// Floor thickness of insert in mm
insert_floor_thickness = 0.8; // [0.4:0.4:2.4]

// Corner radius in mm
corner_radius = 3; // [0:1:8]

// Calculate tolerance based on nozzle diameter
calculated_tolerance = nozzle_diameter / 2;

// Allow manual override of the calculated tolerance
manual_tolerance_override = false; // [true, false]

// Manual tolerance setting (only used if override is enabled)
manual_tolerance = 0.2; // [0:0.05:1]

// Final tolerance value to use
tolerance = manual_tolerance_override ? manual_tolerance : calculated_tolerance;

// Calculate actual dimensions of outer container
outer_width = outer_width_units * 8;
outer_depth = outer_depth_units * 8;
outer_height = outer_height_units * 8;

// Calculate inner dimensions of outer container (where our insert will fit)
outer_inner_width = outer_width - (2 * outer_wall_thickness);
outer_inner_depth = outer_depth - (2 * outer_wall_thickness);
outer_inner_height = outer_height - outer_floor_thickness;

// Calculate max dimensions for the insert (accounting for tolerance)
insert_max_width = outer_inner_width - (2 * tolerance);
insert_max_depth = outer_inner_depth - (2 * tolerance);
insert_max_height = outer_inner_height - (2 * tolerance);

// Calculate inner dimensions of insert
insert_inner_width = insert_max_width - (2 * insert_wall_thickness);
insert_inner_depth = insert_max_depth - (2 * insert_wall_thickness);
insert_inner_height = insert_max_height - insert_floor_thickness;

// Display dimensions and tolerance information
echo("Using nozzle diameter: ", nozzle_diameter);
echo("Calculated tolerance: ", calculated_tolerance);
echo("Final tolerance used: ", tolerance);
echo("Insert max dimensions (w×d×h): ", insert_max_width, "×", insert_max_depth, "×", insert_max_height);
echo("Insert inner dimensions (w×d×h): ", insert_inner_width, "×", insert_inner_depth, "×", insert_inner_height);

// Create insert box
module insert_box() {
    difference() {
        // Outer shape of insert - with flat top
        hull() {
            // Bottom corners
            for (x = [corner_radius, insert_max_width - corner_radius]) {
                for (y = [corner_radius, insert_max_depth - corner_radius]) {
                    translate([x, y, 0])
                    cylinder(h = 0.01, r = corner_radius);
                }
            }
            
            // Top edges - using cylinders for rounded vertical edges, but flat top
            for (x = [corner_radius, insert_max_width - corner_radius]) {
                for (y = [corner_radius, insert_max_depth - corner_radius]) {
                    translate([x, y, insert_max_height - corner_radius])
                    cylinder(h = corner_radius, r = corner_radius);
                }
            }
        }
        
        // Inner cutout
        translate([insert_wall_thickness, insert_wall_thickness, insert_floor_thickness])
        cube([insert_inner_width, insert_inner_depth, insert_inner_height + 1]);
    }
}

// Create the insert box
insert_box();