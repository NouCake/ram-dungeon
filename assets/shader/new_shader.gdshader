shader_type canvas_item;
render_mode skip_vertex_transform;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float lod: hint_range(0.0, 5) = 0.0;
void fragment()
{
	vec3 col = textureLod(SCREEN_TEXTURE, UV, lod).rgb;
	COLOR.rgb = col;
}