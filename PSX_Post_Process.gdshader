//==================================================
// Canvas shader that dithers like the original PlayStation(PSX) does.
//
// It works by converting RGB to HSL and dithers the luminance of the
// colors to its closest color neighbor and converts back to RGB.
//==================================================

shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform int target_width : hint_range(160, 640) = 320;
uniform int target_height : hint_range(120, 480) = 240;
uniform bool dither_on;

// 4x4 Bayer matrix
const float indexMatrix4x4[16] = {
    0.0/16.0,  8.0/16.0,  2.0/16.0,  10.0/16.0,
    12.0/16.0, 4.0/16.0,  14.0/16.0, 6.0/16.0,
    3.0/16.0,  11.0/16.0, 1.0/16.0,  9.0/16.0,
    15.0/16.0, 7.0/16.0,  13.0/16.0, 5.0/16.0
};

float hueToRgb(float temp_1, float temp_2, float hue) {
    if (hue < 0.0) hue += 1.0; //Normalize the color degrees.
    if (hue > 1.0) hue -= 1.0;
    if (hue * 6.0 < 1.0) return temp_2 + (temp_1 - temp_2) * 6.0 * hue;
    if (hue * 2.0 < 1.0) return temp_1;
    if (hue * 3.0 < 2.0) return temp_2 + (temp_1 - temp_2) * (2.0/3.0 - hue) * 6.0;
    return temp_2;
}
vec3 rgbToHsl(vec3 c) {
    float maxC = max(max(c.r, c.g), c.b);
    float minC = min(min(c.r, c.g), c.b);
    float chroma = maxC - minC;
	float lum = (maxC + minC) / 2.0;
	float sat = 0.0;
	float hue = 0.0;
	if (chroma > 0.001) {
		sat = chroma / (1.0 - abs(2.0 * lum - 1.0));
	}
    if (chroma > 0.001) {
        if (abs(c.r-maxC) < 0.001){
            hue = (c.g - c.b) / chroma;
        } else if (abs(c.g-maxC) < 0.001){
            hue = (c.b - c.r) / chroma + 2.0;
        } else {
            hue = (c.r - c.g) / chroma + 4.0;
        }
    }
	hue /= 6.0;
    return vec3(hue, sat, lum);
}
vec3 hslToRgb(vec3 hsl) {
    float hue = hsl.x;
    float sat = hsl.y;
    float lum = hsl.z;
    vec3 rgb;
    if (sat < 0.001) {
        rgb = vec3(lum);
    } else {
        float temp_1 = lum < 0.5 ? lum * (1.0 + sat) : (lum + sat) - (lum * sat);
        float temp_2 = 2.0 * lum - temp_1;
        rgb.r = hueToRgb(temp_1, temp_2, hue + 0.333);
        rgb.g = hueToRgb(temp_1, temp_2, hue);
        rgb.b = hueToRgb(temp_1, temp_2, hue - 0.333);
    }
    return rgb;
}

float indexValue(vec2 screen_pixel) {
    int x = int(mod(screen_pixel.x, 4.0));
    int y = int(mod(screen_pixel.y, 4.0));
    return indexMatrix4x4[x + y * 4];
}
vec3 getPaletteColor(int i) {
	float pallet_color = float(i) / float(64);
	return vec3(pallet_color);
}
float getLuminance(vec3 color) {
	float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
	return (maxC + minC) / 2.0;
}

void closestColors(float luminance, out float closest, out float secondClosest) {
    int closest_idx = 0;
    int second_idx = 1;
    float closest_dist = 1e10;
    float second_dist = 1e10;
    for (int i = 0; i < 32; i++) {
        vec3 pal_color = getPaletteColor(i);
        float pal_lum = getLuminance(pal_color);
        float dist = abs(pal_lum - luminance);
        if (dist < closest_dist) {
            second_idx = closest_idx;
            second_dist = closest_dist;
            closest_idx = i;
            closest_dist = dist;
        } else if (dist < second_dist) {
            second_idx = i;
            second_dist = dist;
        }
    }
    closest = getLuminance(getPaletteColor(closest_idx));
    secondClosest = getLuminance(getPaletteColor(second_idx));
    if (closest > secondClosest) {
        float temp = closest;
        closest = secondClosest;
        secondClosest = temp;
    }
}

float ditherLuminance(float luminance, vec2 screen_pixel) {
    float lum1, lum2;
    closestColors(luminance, lum1, lum2);
    float d = indexValue(screen_pixel);
    if (abs(lum2 - lum1) < 0.001) {
        return lum1;
    }
    float t = (luminance - lum1) / (lum2 - lum1);
    t = clamp(t, 0.0, 1.0);
    return t > d ? lum2 : lum1;
}

vec3 dither(vec3 color, vec2 screen_pixel) {
    vec3 hsl = rgbToHsl(color);
    float original_lum = getLuminance(color);
    float dithered_lum = ditherLuminance(original_lum, screen_pixel);
    float lum_ratio = original_lum > 0.001 ? dithered_lum / original_lum : 0.0;
    hsl.z = hsl.z * lum_ratio;
    hsl.z = clamp(hsl.z, 0.0, 1.0);
    return hslToRgb(hsl);
}

void fragment() {
    vec2 target_res = vec2(float(target_width), float(target_height));
    vec2 pixel_coord = floor(SCREEN_UV * target_res);
    vec2 screen_sample_uv = (pixel_coord + 0.0) / target_res;
    vec3 screen_col = texture(SCREEN_TEXTURE, screen_sample_uv).rgb;
	float screen_alpha = texture(SCREEN_TEXTURE, screen_sample_uv).a;
    vec3 final_col = screen_col;
	if (dither_on) final_col = dither(screen_col, pixel_coord);
    COLOR = vec4(final_col, screen_alpha);
}
