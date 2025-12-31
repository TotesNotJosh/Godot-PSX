# Godot-PSX
Scripts and shaders to get the PSX look in Godot v4.4+

Aseprite Scripts:
    15-bit Quantize - This will quantize the pixels in your current image to 15-bit. I recommend only doing this on smaller images.
    15-bit Color Picker - This creates a dialog box that quantizes to 15-bit and lets you set your foreground and background colors from the dialog box.

Godot Shaders:
    PSX_Post_Process - This is a canvas shader that will dither your screen in a way that is nearly indistinguishable from PSX hardware dithering.
    PSX_Object - Coming soon. This spatial shader will add the following effects, vertex snapping, affine texture warp, and alpha scissoring.

Installation:
    For the Asperite scripts add them to your Asperite Script folder.
    For the Post Processing shader create a CanvasLayer node, as a child create a ColorRect node. In the layout settings of the ColorRect node set the anchors preset to Full Rect. Set the container sizing to expand for both horizontal and vertical options. Under Material add a new shader material and under Shader select the PSX_Post_Process shader. Set your target width and target height to a 4:3 aspect ratio. 320 x 240 is recommended to match NTSC sizing and 320 x 256 for PAL sizing. For interlaced sizing 640 x 480 for NTSC and 640 x 512 for PAL. These values come from the settings for the PSX's frame buffer.