// Drawer Organization System - Container with Decorative Mesh Pattern
// All dimensions in mm, based on multiples of 8mm

/* [Printer Settings] */
// Nozzle diameter in mm
nozzle_diameter = 0.6; // [0.2, 0.4, 0.6, 0.8]

/* [Container Dimensions] */
// Width of container in grid units (1 unit = 8mm)
width_units = 10; // [1:50]

// Depth of container in grid units (1 unit = 8mm)
depth_units = 15; // [1:50]

// Height of container in grid units (1 unit = 8mm)
height_units = 6; // [1:20]

// Floor thickness in mm (using 2.4mm = 8mm/3.333)
floor_thickness = 2.4; // [1.6:0.8:4.0]

// Wall thickness in mm (using 2.4mm = 8mm/3.333)
wall_thickness = 2.4; // [1.6:0.8:4.0]

// Corner radius in mm
corner_radius = 4; // [0:1:16]

/* [Stacking Features] */
// Enable stacking features (inset bottom)
stackable = true; // [true, false]

// Inset height at bottom for stacking in mm
lip_height = 3.2; // [2.4:0.8:4.8]

// Inset width from edge at bottom for stacking in mm
lip_width = 3.2; // [2.4:0.8:4.8]

// Calculate tolerance based on nozzle diameter
// Using half of the nozzle diameter as recommended
calculated_tolerance = nozzle_diameter / 2;

// Allow manual override of the calculated tolerance
manual_tolerance_override = false; // [true, false]

// Manual tolerance setting (only used if override is enabled)
manual_tolerance = 0.2; // [0:0.05:1]

// Final tolerance value to use
tolerance = manual_tolerance_override ? manual_tolerance : calculated_tolerance;

/* [Mesh Pattern] */
// Enable mesh pattern
mesh_pattern = true; // [true, false]

// Mesh pattern style
mesh_style = "hexagonal"; // ["hexagonal", "diamond", "square", "lines"]

// Mesh hole size in mm
mesh_size = 8; // [4:1:16]

// Mesh wall thickness in mm
mesh_thickness = 1.6; // [1.2:0.4:2.4]

// Mesh safe zone (solid border) in mm
mesh_safe_zone = 13; // [1:0.5:5]

/* [Additional Features] */
// Add finger notch for easy access
finger_notch = true; // [true, false]

// Add label area on one side
label_area = false; // [true, false]

// Add dividers
dividers = 0; // [0:5]

// Calculate actual dimensions
width = width_units * 8;
depth = depth_units * 8;
height = height_units * 8;
inner_width = width - (2 * wall_thickness);
inner_depth = depth - (2 * wall_thickness);
inner_height = height - floor_thickness;

// Display tolerance information
echo("Using nozzle diameter: ", nozzle_diameter);
echo("Calculated tolerance: ", calculated_tolerance);
echo("Final tolerance used: ", tolerance);

// Create container
module container() {
    difference() {
        // Single unified outer shell with inset bottom for stacking
        hull() {
            // Bottom corners - NARROWER at z=0 by lip_width for the inset stacking feature
            for (x = [lip_width + corner_radius, width - lip_width - corner_radius]) {
                for (y = [lip_width + corner_radius, depth - lip_width - corner_radius]) {
                    translate([x, y, 0])
                    cylinder(h = 0.01, r = corner_radius);
                }
            }
            
            // Points at lip_height (full width/depth where the inset transitions to full width)
            for (x = [corner_radius, width - corner_radius]) {
                for (y = [corner_radius, depth - corner_radius]) {
                    translate([x, y, lip_height])
                    cylinder(h = 0.01, r = corner_radius);
                }
            }
            
            // Top corners (at height - corner_radius)
            for (x = [corner_radius, width - corner_radius]) {
                for (y = [corner_radius, depth - corner_radius]) {
                    translate([x, y, height - corner_radius])
                    sphere(r = corner_radius);
                }
            }
        }
        
        // Inner cutout for the container cavity - only up to the main container height, not extended
        translate([wall_thickness, wall_thickness, floor_thickness])
        cube([inner_width, inner_depth, height]);
        
        // Mesh pattern cutouts
        if (mesh_pattern) {
            // Space for pattern only exists above the bevel and below the top edge minus the safe zone
            pattern_start_z = lip_height + floor_thickness + mesh_thickness;
            
            // Pattern height now considers the fixed safe zone at top
            pattern_height = height - pattern_start_z - mesh_safe_zone;
            
            if (pattern_height > mesh_size) {
                // Create mesh pattern based on selected style
                if (mesh_style == "hexagonal") {
                    hexagonal_mesh(pattern_start_z, pattern_height);
                } else if (mesh_style == "diamond") {
                    diamond_mesh(pattern_start_z, pattern_height);
                } else if (mesh_style == "square") {
                    square_mesh(pattern_start_z, pattern_height);
                } else if (mesh_style == "lines") {
                    lines_mesh(pattern_start_z, pattern_height);
                }
            }
        }
        
        // Finger notch for access (on shorter dimension)
        if (finger_notch) {
            if (width < depth) {
                translate([width/2, 0, height/2])
                rotate([90, 0, 0])
                cylinder(h = wall_thickness * 2, r = height/4, center = true);
            } else {
                translate([0, depth/2, height/2])
                rotate([0, 90, 0])
                cylinder(h = wall_thickness * 2, r = height/4, center = true);
            }
        }
        
        // Label area on one side
        if (label_area) {
            translate([width/4, depth - (wall_thickness/2), height/4])
            cube([width/2, wall_thickness, height/2]);
        }
    }
    
    // Add dividers if requested
    if (dividers > 0) {
        divider_spacing = inner_width / (dividers + 1);
        for (i = [1:dividers]) {
            translate([wall_thickness + (i * divider_spacing), wall_thickness, floor_thickness])
            cube([wall_thickness/2, inner_depth, inner_height * 0.8]);
        }
    }
}

// Hexagonal mesh pattern
module hexagonal_mesh(start_z, height) {
    hex_width = mesh_size;
    hex_height = mesh_size * sqrt(3)/2;
    wall_offset = wall_thickness + mesh_thickness;
    
    // Front face
    for (x = [wall_offset : hex_width*1.5 : width - wall_offset]) {
        for (z = [start_z : hex_height*2 : start_z + height]) {
            translate([x, wall_thickness/2, z])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
            
            translate([x + hex_width*0.75, wall_thickness/2, z + hex_height])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
        }
    }
    
    // Back face
    for (x = [wall_offset : hex_width*1.5 : width - wall_offset]) {
        for (z = [start_z : hex_height*2 : start_z + height]) {
            translate([x, depth - wall_thickness/2, z])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
            
            translate([x + hex_width*0.75, depth - wall_thickness/2, z + hex_height])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
        }
    }
    
    // Left face
    for (y = [wall_offset : hex_width*1.5 : depth - wall_offset]) {
        for (z = [start_z : hex_height*2 : start_z + height]) {
            translate([wall_thickness/2, y, z])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
            
            translate([wall_thickness/2, y + hex_width*0.75, z + hex_height])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
        }
    }
    
    // Right face
    for (y = [wall_offset : hex_width*1.5 : depth - wall_offset]) {
        for (z = [start_z : hex_height*2 : start_z + height]) {
            translate([width - wall_thickness/2, y, z])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
            
            translate([width - wall_thickness/2, y + hex_width*0.75, z + hex_height])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness+0.1, r = hex_width/2, $fn=6, center = true);
        }
    }
}

// Diamond mesh pattern
module diamond_mesh(start_z, height) {
    diamond_size = mesh_size;
    wall_offset = wall_thickness + mesh_thickness;
    
    // Front face
    for (x = [wall_offset : diamond_size : width - wall_offset]) {
        for (z = [start_z : diamond_size : start_z + height]) {
            translate([x, wall_thickness/2, z])
            rotate([45, 0, 45])
            cube([diamond_size/2, diamond_size/2, diamond_size/2], center = true);
        }
    }
    
    // Back face
    for (x = [wall_offset : diamond_size : width - wall_offset]) {
        for (z = [start_z : diamond_size : start_z + height]) {
            translate([x, depth - wall_thickness/2, z])
            rotate([45, 0, 45])
            cube([diamond_size/2, diamond_size/2, diamond_size/2], center = true);
        }
    }
    
    // Left face
    for (y = [wall_offset : diamond_size : depth - wall_offset]) {
        for (z = [start_z : diamond_size : start_z + height]) {
            translate([wall_thickness/2, y, z])
            rotate([45, 0, 45])
            cube([diamond_size/2, diamond_size/2, diamond_size/2], center = true);
        }
    }
    
    // Right face
    for (y = [wall_offset : diamond_size : depth - wall_offset]) {
        for (z = [start_z : diamond_size : start_z + height]) {
            translate([width - wall_thickness/2, y, z])
            rotate([45, 0, 45])
            cube([diamond_size/2, diamond_size/2, diamond_size/2], center = true);
        }
    }
}

// Square mesh pattern
module square_mesh(start_z, height) {
    square_size = mesh_size;
    spacing = square_size * 1.5;
    wall_offset = wall_thickness + mesh_thickness;
    
    // Front face
    for (x = [wall_offset : spacing : width - wall_offset]) {
        for (z = [start_z : spacing : start_z + height]) {
            translate([x, 0, z])
            cube([square_size, wall_thickness + 0.1, square_size], center = false);
        }
    }
    
    // Back face
    for (x = [wall_offset : spacing : width - wall_offset]) {
        for (z = [start_z : spacing : start_z + height]) {
            translate([x, depth - wall_thickness - 0.05, z])
            cube([square_size, wall_thickness + 0.1, square_size], center = false);
        }
    }
    
    // Left face
    for (y = [wall_offset : spacing : depth - wall_offset]) {
        for (z = [start_z : spacing : start_z + height]) {
            translate([0, y, z])
            cube([wall_thickness + 0.1, square_size, square_size], center = false);
        }
    }
    
    // Right face
    for (y = [wall_offset : spacing : depth - wall_offset]) {
        for (z = [start_z : spacing : start_z + height]) {
            translate([width - wall_thickness - 0.05, y, z])
            cube([wall_thickness + 0.1, square_size, square_size], center = false);
        }
    }
}

// Horizontal lines mesh pattern
module lines_mesh(start_z, height) {
    line_spacing = mesh_size;
    line_thickness = mesh_size / 4;
    wall_offset = wall_thickness + mesh_thickness;
    
    for (z = [start_z : line_spacing * 2 : start_z + height]) {
        // Front face lines
        translate([wall_offset, 0, z])
        cube([width - 2*wall_offset, wall_thickness + 0.1, line_thickness], center = false);
        
        // Back face lines
        translate([wall_offset, depth - wall_thickness - 0.05, z])
        cube([width - 2*wall_offset, wall_thickness + 0.1, line_thickness], center = false);
        
        // Left face lines
        translate([0, wall_offset, z])
        cube([wall_thickness + 0.1, depth - 2*wall_offset, line_thickness], center = false);
        
        // Right face lines
        translate([width - wall_thickness - 0.05, wall_offset, z])
        cube([wall_thickness + 0.1, depth - 2*wall_offset, line_thickness], center = false);
    }
}

// Create the container
container();

/* 
Example dimensions for 320×400mm drawer:
- Pencil holder: width_units=10, depth_units=25, height_units=10 (80mm tall)
- Small square: width_units=10, depth_units=10, height_units=5 (40mm tall)
- Medium container: width_units=15, depth_units=15, height_units=5 (40mm tall)
- Small rectangle: width_units=15, depth_units=10, height_units=5 (40mm tall)
- Long container: width_units=25, depth_units=9, height_units=4 (32mm tall)
- Large container: width_units=21, depth_units=26, height_units=8 (64mm tall)
- Small rectangle 2: width_units=11, depth_units=9, height_units=4 (32mm tall)
*/