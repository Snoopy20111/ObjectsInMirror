shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float wiggle = 0.0;
uniform float offset = 0.0;

void fragment() {
	vec4 green_channel = texture(screen_texture, SCREEN_UV, SCREEN_UV.y);
	vec4 red_channel = texture(screen_texture, vec2(SCREEN_UV.x + (offset + sin(TIME * wiggle)) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y));
	vec4 blue_channel = texture(screen_texture, vec2(SCREEN_UV.x - (offset + cos(TIME * wiggle)) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y));
	COLOR.rgb = vec3(red_channel.r, green_channel.g, blue_channel.b);
}