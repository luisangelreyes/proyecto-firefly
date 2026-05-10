shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int filtro_tipo : hint_range(0, 3) = 0;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    if (filtro_tipo == 0) {
        COLOR = color;
    } else {
        mat3 m;
        if (filtro_tipo == 1) {
            // Protanopía
            m = mat3(
                vec3(0.0, 1.05118294, -0.05116099),
                vec3(0.0, 1.0, 0.0),
                vec3(0.0, 0.0, 1.0)
            );
        } else if (filtro_tipo == 2) {
            // Deuteranopía
            m = mat3(
                vec3(1.0, 0.0, 0.0),
                vec3(0.494207, 0.0, 1.24827),
                vec3(0.0, 0.0, 1.0)
            );
        } else {
            // Tritanopía
            m = mat3(
                vec3(1.0, 0.0, 0.0),
                vec3(0.0, 1.0, 0.0),
                vec3(-0.86744736, 1.86727089, 0.0)
            );
        }
        
        COLOR = vec4(m * color.rgb, color.a);
    }
}