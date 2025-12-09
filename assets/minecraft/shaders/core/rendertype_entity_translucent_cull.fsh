#version 330

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    
    // Detect area effect cloud by its specific magenta color (R=1, B=1, G≈0)
    if (color.a > 0.5 && color.r > 0.9 && color.b > 0.9 && color.g < 0.1) {
        // Write signal to bottom-left corner of screen
        if (gl_FragCoord.x < 1.0 && gl_FragCoord.y < 1.0) {
            fragColor = vec4(1.0, 0.0, 1.0, 1.0); // Magenta signal
            return;
        }
    }
    
    color *= vertexColor * ColorModulator;
    
    if (color.a < 0.1) {
        discard;
    }
    
    fragColor = color;
}