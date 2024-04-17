
 $fn = 128;

section_model = false;
radius_factor = 0.999;

default_thickness = 7.999;



parts = [

// First Part 
[
  [ //Segments
      [
        0, // Length (mm)
        27.95 // Inner Radius (mm)
        //,100,  // Outer radius (mm)
      ],
      [
        5.7,  // Length (mm)
        30
        //,110, // Inner Radius (mm)
        
      ],
      [
        9.8, // Length (mm)
        30 // Inner Radius (mm)
        //,120, // Outer radius (mm)
      ],
    
  ],
   
  [ //Features
  
      //Round Hole (5 numbers)
      [
        false, // Solid
        5, // Position (mm)
        30, // Position (deg)
        9, // Inner Diameter (mm)
        13, // Outer Diameter (mm)
        2, //Diameter Hole (mm)
      ],
      
      //Rectangular Hole (6 numbers
      [
        false, // Solid
        5, // Position (mm)
        30, // Position (deg)
        9, // Inner Diameter (mm)
        13, // Outer Diameter (mm)
        2, // Length (mm)
        10, // Width (deg)
      ],
      
      //Repeated Rectangle /Grip (7 Numbers)
      [
        true, // Solid
        1, // Position (mm)
        0, // Position (deg)
        12, // Inner Diameter (mm)
        13, // Outer Diameter (mm)
        8, // Length (mm)
        1, // Width (deg)
        30, // Count (integer)
      ]
  ]
  
],

 //Second Part
[
    [ //Segments
        [
            -9,
            39,
            43
        ],
        [
            10,
            39,
            43
        ],
        [
            0,
            30,
            43
        ],
        [
            100,
            30,
            43
        ]

    ],
    
    
[] //Features

],


// Third Part
[
    [ //Segments
        [
            500,
            50,
            100
        ],
        [
            100,
            50,
            100
        ]

    ],
    
    
[] //Features

]




];




num_parts = len(parts);
echo(str("num_parts: ",num_parts));



//https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Add_all_values_in_a_list
function sum(v) = [for(p=v) 1]*v;
    





    


module makeParts(){


for(part_idx = [0:1:num_parts-1]){
    
    echo(str("part_idx: ",part_idx));   
    part = parts[part_idx];
    echo(str("part: ",part));   
    
    
    assert(len(part)==2, "Each part vector must only have two values");
    
    //Get the number of segments
    segments = part[0];
    num_segments = len(segments);
    echo(str("num_segments: ",num_segments));
    
    
    //Convert Radii into Y values
    inner_radii = [for( i = [0:1:num_segments-1]) segments[i][1] ];
    echo(str("inner_radii: ",inner_radii));    
        
    outer_radii_rev = [for( i = [num_segments-1:-1:0]) len(segments[i]) > 2 ? segments[i][2] : segments[i][1]+default_thickness];
    echo(str("outer_radii_rev: ",outer_radii_rev));    
        
    y_values = concat(inner_radii,outer_radii_rev);
    echo(str("y_values: ",y_values));
    
    
    //TODO: Calcuate x_start of part from sum of lenths of previous parts
    
    //Calculate the start position of the part from the sum of the segments of the previous parts
    prev_seg_lengths = [for(i = [0:1:part_idx-1]) for(j = [0:1:len(parts[i][0])-1]) parts[i][0][j][0]];
    echo(str("prev_seg_lengths: ",prev_seg_lengths));
    
    x_start = sum(concat(0,prev_seg_lengths));
    echo(str("x_start: ",x_start));
    
    // Create a vector of the x values from start to end
    x_values_fwd = [for( i = [0:1:num_segments-1]) sum([for(j = [0:1:i]) segments[j][0]]) + x_start];
    //echo(str("x_values_fwd: ",x_values_fwd));
        
    //Reverse the list of x values
    x_values_rev =  [for( i = [num_segments-1:-1:0]) x_values_fwd[i] ];
    //echo(str("x_values_rev: ",x_values_rev));
        
    //Join the fwd and rev lists
    x_values = concat(x_values_fwd,x_values_rev);
    //echo(str("x_values: ",x_values));
    
    //Combine x values and y values into vector of points
    points = [for(i = [0:1:num_segments*2-1]) [x_values[i],y_values[i]]];
    echo(str("points: ",points));
    
    //Create the part
    rotate_extrude(angle=360)
    rotate([0,0,90])
    polygon(points);
}






}




if(section_model == true)
    difference(){
    makeParts();   
        cubeSize=1000;
       translate([0,-cubeSize/2,0])
    cube(cubeSize);    
    }

else makeParts();