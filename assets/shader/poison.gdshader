shader_type spatial;

render_mode blend_mix, unshaded;

uniform float scale : hint_range(0.1, 10.0) = 3;
uniform float rim_strength : hint_range(0.0, 5.0) = 2.0;
uniform vec4 rim_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.0);
uniform float rim_power : hint_range(0.1, 10.0) = 3.0;
uniform float offset_strength : hint_range(0.0, 2.0);
instance uniform float fade : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

varying float displacement;

// Hash function for noise generation
vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// Perlin noise function
float perlin_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	
	// Cubic interpolation curve
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	// Calculate gradients at corners
	float a = dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
	float b = dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
	float c = dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
	float d = dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
	
	// Interpolate
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 noise_offset = (MODEL_MATRIX * vec4(1.0)).xz;
	float noise = perlin_noise((UV + noise_offset) * scale + vec2(1.0) * TIME * 0.3);
	
	float dist_to_center = distance(UV, vec2(0.5));
	float radius   = 0.4;
	float softness = 0.1; // edge width in UV space
	float circle = 1.0 - smoothstep(
	    radius - softness,
	    radius + softness,
	    dist_to_center
	);
	
	displacement = (noise + 0.5)  * circle;
	VERTEX.y += displacement * offset_strength;
}

float rim_light(vec3 vertex, vec3 view, vec3 normal) {
	vec3 view_dir = normalize(vertex - view);
	float rim = 1.0 - max(dot(normal, -view_dir), 0.0);
	return pow(rim, rim_power) * rim_strength;
}

float quantasize(float value, float n) {
	float stepped_value = floor(value * (n - 1.0)) / (n - 1.0);
	return stepped_value;
}

vec3 quantasize(vec3 value, float n) {
	return vec3(
		quantasize(value.x, n),
		quantasize(value.y, n),
		quantasize(value.z, n)
	);
}

void fragment() {
	vec3 rim_light = rim_color.rgb;
	
    float scene_depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float dist_to_center = distance(UV, vec2(0.5));
	float radius   = 0.45;
	float softness = 0.05; // edge width in UV space
	float circle = 1.0 - smoothstep(
	    radius - softness,
	    radius + softness,
	    dist_to_center
	);
	
	float cutoff = step(dist_to_center, 0.5);
	//ALBEDO = mix(base_color.rgb, rim_color.rgb, displacement) + rim_light;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, scene_depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float linear_depth = -(view.xyz/view.w).z; // This is your distance in world units
	
	float depth_difference = clamp((linear_depth + VERTEX.z) * 2.0, 0.0, 0.5);
	ALBEDO = quantasize(mix(base_color.rgb, rim_color.rgb, displacement), 32.0);
	ALPHA = quantasize(min(cutoff, depth_difference * circle * (displacement + 0.5)) * fade, 32.0);
}