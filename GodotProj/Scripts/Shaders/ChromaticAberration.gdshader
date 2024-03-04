shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 bg = texture(screen_texture, SCREEN_UV);
	float avg = (bg.r + bg.g +bg.b) /3.0;
	COLOR = vec4(avg, avg, avg, 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
