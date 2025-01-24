shader_type canvas_item;

uniform vec4 color : source_color;

uniform sampler2D fast_noise : repeat_enable;
uniform sampler2D caustics : repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 speed = vec2(0.03, 0.07);

uniform float wave_strength = 2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	// Called for every pixel the material is visible on.
	vec2 uv = vec2(floor(UV.x / pixel_size.x) * pixel_size.x, floor(UV.y / pixel_size.y) * pixel_size.y) + speed * TIME;
	vec2 noise = texture(fast_noise, uv).rg;

	vec4 caus = texture(caustics, uv + noise * (wave_strength / 100.0)).rgba;



	COLOR = vec4(color.r, color.g, color.b, 1) + caus;

	COLOR *= texture(screen_content, SCREEN_UV + noise * (wave_strength / 100.0));

}