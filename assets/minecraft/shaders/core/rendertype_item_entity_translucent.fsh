#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    
float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
float nightFactor = smoothstep(0.6, 0.15, brightness); 
    
    float envStart = mix(FogEnvironmentalStart, 5.0, nightFactor);
    float envEnd = mix(FogEnvironmentalEnd, 10.0, nightFactor);
    
    float fogDistance = mix(sphericalVertexDistance, cylindricalVertexDistance, nightFactor);
    
    fragColor = apply_fog(color, fogDistance, fogDistance, envStart, envEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}