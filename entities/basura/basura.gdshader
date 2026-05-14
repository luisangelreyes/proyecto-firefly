shader_type canvas_item;

uniform vec4 color_borde : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float grosor : hint_range(0.0, 5.0) = 1.0;
uniform bool activar_borde = true;

void fragment() {
	vec4 color_original = texture(TEXTURE, UV);
	
	if (activar_borde && color_original.a == 0.0) {
		vec2 size = TEXTURE_PIXEL_SIZE * grosor;
		float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
		outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
		outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		outline = min(outline, 1.0);
		
		COLOR = vec4(color_borde.rgb, outline * color_borde.a);
	} else {
		COLOR = color_original;
	}
}