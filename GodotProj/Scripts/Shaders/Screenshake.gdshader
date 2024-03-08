/*
	Camera Shake Effect Shader by @Near
	MIT License
*/

shader_type canvas_item;
uniform float shake_strength = 0;
uniform vec2 factor_a  = vec2(100.0, 100.0);
uniform vec2 factor_b  = vec2(1.0, 1.0);
uniform vec2 magnitude = vec2(0.01, 0.01);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
	uv -= 0.5;
    uv *= 1.0 - 2.0 * magnitude.x;
    uv += 0.5;
	vec2 dt = vec2(0.0, 0.0);
	dt.x = sin(TIME * factor_a.x + factor_b.x) * magnitude.x;
	dt.y = cos(TIME * factor_a.y + factor_b.y) * magnitude.y;
	COLOR = texture(SCREEN_TEXTURE, uv + (dt * shake_strength));
}