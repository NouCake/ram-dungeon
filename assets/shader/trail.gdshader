shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	ALBEDO = vertex_color.rgb;
	ALPHA = vertex_color.a;
}
