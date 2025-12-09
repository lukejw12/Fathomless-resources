#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;
flat in float isMarker;
flat in vec4 tint;

out vec4 fragColor;

void main() {
    if (isMarker > 0.5) {
        // This is a marker particle
        ivec2 iCoord = ivec2(gl_FragCoord.xy);
        
        // Only draw at pixel (0,0) for G=253 marker
        if (abs(tint.g * 255.0 - 253.0) < 0.5 && iCoord == ivec2(0, 0)) {
            fragColor = vec4(254.0/255.0, tint.gb, 1.0);
        } else if (abs(tint.g * 255.0 - 252.0) < 0.5 && iCoord == ivec2(0, 2)) {
            fragColor = vec4(254.0/255.0, tint.gb, 1.0);
        } else {
            discard;
        }
    } else {
        // Normal particle rendering (vanilla code)
        vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
        if (color.a < 0.1) {
            discard;
        }
        fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
    }
}