
shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
uniform float pixel_size : hint_range(1.0, 20.0) = 2.0;
uniform float levels : hint_range(1.0, 100.0) = 5.0;
uniform vec2 gamma = vec2(1.0, 1.0);

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    // Pixelation effect
    vec2 texture_size = vec2(textureSize(screen_texture, 0));
    vec2 pixel_count = texture_size / (pixel_size * 2.0);
    vec2 pixelated_uv = floor(SCREEN_UV * pixel_count) / pixel_count;

    vec3 color = texture(screen_texture, pixelated_uv).rgb;

    // Posterization effect
    color = pow(max(color, vec3(0.0)), vec3(gamma.x));

    float grayscale = max(color.r, max(color.g, color.b));

    float safe_levels = max(levels, 1.0);
    float lower = floor(grayscale * safe_levels) / safe_levels;
    float higher = ceil(grayscale * safe_levels) / safe_levels;

    float lower_diff = abs(lower - grayscale);
    float higher_diff = abs(higher - grayscale);

    float level = (lower_diff < higher_diff) ? lower : higher;
    float adjustment = grayscale > 0.0001 ? level / grayscale : 0.0;

    color *= adjustment;
    color = pow(max(color, vec3(0.0)), vec3(gamma.y));

    ALBEDO = color;
}
