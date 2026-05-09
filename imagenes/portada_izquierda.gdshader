shader_type canvas_item;

// Controla qué tan avanzada va la animación (de 0.0 a 1.0)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Controla qué tan ancho o pronunciado es el cilindro del doblez
uniform float radius = 0.1;

void fragment() {
    vec2 uv = UV;
    
    // Calculamos la distancia desde el punto de doblez actual
    float dist = uv.x - (1.0 - progress);
    
    if (dist > radius) {
        // Si el píxel ya pasó el doblez, lo hacemos transparente
        COLOR.a = 0.0;
    } else if (dist > 0.0) {
        // Si el píxel está justo en la zona del doblez, calculamos la curva
        vec2 curled_uv = vec2(1.0 - progress - dist, uv.y);
        
        // Obtenemos la textura y la oscurecemos un poco para simular sombra
        COLOR = texture(TEXTURE, curled_uv);
        COLOR.rgb *= 0.8; 
    } else {
        // Si el píxel aún no ha sido tocado por el doblez, se dibuja normal
        COLOR = texture(TEXTURE, uv);
    }
}