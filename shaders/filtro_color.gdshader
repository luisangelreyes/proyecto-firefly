shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int filtro_tipo : hint_range(0, 3) = 0;

mat3 matriz_protanopia() {
    return mat3(
        vec3(0.567, 0.433, 0.0),
        vec3(0.558, 0.442, 0.0),
        vec3(0.0, 0.242, 0.758)
    );
}

mat3 matriz_deuteranopia() {
    return mat3(
        vec3(0.625, 0.375, 0.0),
        vec3(0.700, 0.300, 0.0),
        vec3(0.0, 0.300, 0.700)
    );
}

mat3 matriz_tritanopia() {
    return mat3(
        vec3(0.950, 0.050, 0.0),
        vec3(0.0, 0.433, 0.567),
        vec3(0.0, 0.475, 0.525)
    );
}

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    if (filtro_tipo == 0) {
        COLOR = color;
    } else {
        mat3 m;
        if (filtro_tipo == 1) {
            m = matriz_protanopia();
        } else if (filtro_tipo == 2) {
            m = matriz_deuteranopia();
        } else {
            m = matriz_tritanopia();
        }
        
        vec3 resultado = m * color.rgb;
        COLOR = vec4(clamp(resultado, 0.0, 1.0), color.a);
    }
}