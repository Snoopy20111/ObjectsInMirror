shader_type canvas_item;

uniform float alpha = 0.4;
uniform float inner_radius = 0.8;
uniform float outer_radius = 1.1;

void fragment() {
	float x = abs(UV.r-.5)*2.0;
	float y = abs(UV.g-.5)*2.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);
	COLOR = vec4(0, 0, 0, q*alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
