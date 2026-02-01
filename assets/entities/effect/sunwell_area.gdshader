shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D sheet;
uniform float frames = 6.0;
uniform float fps = 12.0;

uniform float scroll_speed = 0.15;
uniform vec2 uv_scale = vec2(1.0, 1.0);

// NEW: manual offset (in UV space). Example: (0.1, 0.0) shifts around ring.
uniform vec2 uv_offset = vec2(0.0, 0.0);

uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
    float f = floor(mod(TIME * fps, frames));

    vec2 uv = UV;

    // scale + manual offset
    uv = uv * uv_scale + uv_offset;

    // scroll around ring (U)
    uv.x = fract(uv.x + TIME * scroll_speed);

    // select frame from 1x6 sheet
    uv.x = (uv.x + f) / frames;

    vec4 c = texture(sheet, uv) * tint;
    ALBEDO = c.rgb;
    ALPHA = c.a;
}
