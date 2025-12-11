#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

in float sphericalVertexDistance;
in float cylindricalVertexDistance;

out vec4 fragColor;

void main() {
float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
float nightFactor = smoothstep(0.6, 0.15, brightness);
    
    float skyEnd = mix(FogSkyEnd, 3.0, nightFactor);
    
    float fogDistance = mix(sphericalVertexDistance, cylindricalVertexDistance, nightFactor);
    
    fragColor = apply_fog(ColorModulator, fogDistance, fogDistance, 0.0, skyEnd, skyEnd, skyEnd, FogColor);
}