shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform sampler2D main_texture : source_color, filter_nearest;
instance uniform float skew_amount : hint_range(-0.5, 0.5) = 0.0;
instance uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool enable_billboard = true;

void vertex() {
	// Billboard effect - make the sprite face the camera
	if (enable_billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0],
			INV_VIEW_MATRIX[1],
			INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]
		);
	}
	
	// UV.y goes from 0 (top) to 1 (bottom)
	// We subtract 0.5 so the middle stays still while top/bottom move in opposite directions
	float skew_offset = (1.0 - UV.y) * skew_amount;
	VERTEX.x += skew_offset;
}

void fragment() {
	vec4 color = texture(main_texture, UV);
    vec3 flash_mix = mix(color.rgb, flash_color.rgb, flash_modifier);
    
    ALBEDO = flash_mix;
    ALPHA = color.a;
}