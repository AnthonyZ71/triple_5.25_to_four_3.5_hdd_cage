# Overview
OpenSCAD project to create a cage that fits in 3 5.25" drive bays and holds 4 3.5" hard drives using rails.

Optionally supports a fan shroud to provide additional airflow to the drives.

You need to print:

- 1 cage-cage.stl
- 8 cage-rail.stl
- [optional] 4 cage-fan_mounting_pin.stl
- [optional] 1 of the cage-fan_shroud stl files.

Note:  Monitor the print closely when printing the fan mounting pins.
They are very small and can detach from the bed fairly easily.
If you continue to have problems, perhaps print the pins on a raft.

Pictures are of the cage-fan_shroud_web.stl

Note that the cage has a cylinder channel cut out at the top and bottom on one side.
The channel is for routing the power cable of the fan to the back of the case.
It should be on the left side of the cage when it is inserted into the case.

- Code: [Github Repository](https://github.com/AnthonyZ71/triple_5.25_to_four_3.5_hdd_cage)
- STLs:
  - [Prusa Printers](https://www.prusaprinters.org/prints/120546-triple-525-bay-to-four-35-hard-drives-cage)

# Printing Notes
All parts except the rail are designed to be printed without supports.

I print all parts except the rail with typical settings for the material in which they are being printed.
- 5% infill is sufficient

For the rail:
- Plater -> 5% infill
- Plater -> Support on build plate only
- Print Settings -> Layers and perimeters -> Vertical shells -> Perimeters: 3
- Print Settings -> Layers and perimeters -> Quality -> Detect bridging perimeters: true
- Print Settings -> Support material -> Support material -> Overhang threshold -> 40

This should cause very little support to be generated by the pegs for the hard drives and the clip for latching into the cage.
The rest of the rail should not require support.

Note that the number of perimeters is increased from 2 to 3 to ensure that the pin of the rail is solid.
Check the result of slicing the rail, you only need enough perimeters to ensure a solid pin.

## Optional test print
The cage-test.stl doesn't need to be printed at all unless you want to test the tolerances with your printer before committing to a full print.
The components of the test print are all oriented as they would be printed individually, and allows validation of size / spacing of the print before committing the time to print all of the components.
The parts of the test print are:
- A single full channel and rail to allow validation that the rail slides easily and locks into the cage.
- A single fan shroud mounting pin to ensure that it will connect the front of the case to the fan shroud
- A slice of the cage to validate that it will slide into the bay openings for your computer
- A small portion of the fan shroud to ensure that the mounting pin will connect the shroud to the front of the cage.  (note that it is ok that the pin spins in the mounting holes.  Once all four pins lock the shroud to the full cage, it prevents movement.)

# My Equipment
- Prusa MK3
- PrusaSlicer-2.3.3

# References

Several other projects aided in the creation on this HDD cage.

## Modified Parametric Pin Connectors
This project makes use of [Modified Parametric Pin Connectors](https://www.thingiverse.com/thing:3218332) by [acwest](https://www.thingiverse.com/acwest/designs) on thingiverse.  After testing other fan mounting mechanisms, I liked using this pin and socket mechanism, primarily because even if I end up accidentally breaking a pin, printing out a new part is minutes, not hours.

## Customizable Fan Grill Covers
This project makes use of [Customizable Fan Grill Covers](https://www.thingiverse.com/thing:4837562) by [OutwardB](https://www.thingiverse.com/OutwardB) on thingiverse.

Several preset grills are provided using these settings:

all:
- Frame -> fan preset: 120mm
- Frame -> frame option: full
- Frame -> screw hole chamfer: bottom
- Frame -> min border size in millimeter: 5
- Pattern -> line size in millimeter: 1.6
- Advanced | Frame Setting -> rounded corners: no

crosshair
- Pattern -> grill pattern: crosshair
- Pattern -> line space in millimeter:  19.0

crosshex
- Pattern -> grill pattern: crosshex
- Pattern -> line space in millimeter:  8.0

grid:
- Pattern -> line space in millimeter:  8.0

teardrop:
- Pattern -> line space in millimeter:  8.0
- Pattern -> grill pattern rotation: 180

web:
- Pattern -> grill pattern: web
- Pattern -> line space in millimeter:  19.0

none:
- Frame -> screw hole chamfer: no

To create a custom grill, you can use any STL file that fits the grill pattern with the expectation that the front of the grill is what is facing down on the printer bed and that the center of the grill is at the origin [0, 0, 0] when the STL is loaded into OpenSCAD.
Use the settings describe above if using OutwardB's custom fan grill cover generator, and then make the desired changes, render, and export the STL as fan_cover_custom.stl
Then in OpenSCAD, select "fan_shroud" as the part, grill style of custom.
You will then see the customized fan shroud.
Render it and export the STL.

# Final Note
The current pictures are of an early iteration that used hinges for the fan shroud/cage instead of the pins.
The fan shroud was painted black to match the case.
All of the testing of the design worked fine until it was put into the case for actual use.
The fan shroud does not open far enough to access the drives.
With the fan shroud attached, the front of the case cannot be removed.
See the makes for pictures of the new design and I will update my photos when I reprint the case in the future.
The latest iteration is much better than the photos.

