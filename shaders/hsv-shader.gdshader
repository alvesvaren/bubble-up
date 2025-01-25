shader_type canvas_item;

uniform float hue_shift : hint_range(0.0,1.0) = 0.0;
uniform float sat_mul : hint_range(0.0,10.0) = 1.0;
uniform float val_mul : hint_range(0.0,10.0) = 1.0;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;

    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
	vec3 color_hsv = rgb2hsv(texture_color.rgb);
	color_hsv.x = mod((color_hsv.x + hue_shift), 1.0);
	color_hsv.y = min((color_hsv.y * sat_mul), 1.01);
	color_hsv.z = min((color_hsv.z * val_mul), 1.01);
	vec3 color_rgb = hsv2rgb(color_hsv);
	COLOR.rgba = vec4(color_rgb.rgb,texture_color.a);
}
