#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

in float sphericalVertexDistance;
in float cylindricalVertexDistance;

out vec4 fragColor;

void main() {
    // Detect night by fog color brightness
    // Smoother night detection (gradual transition as sun sets)
float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
float nightFactor = smoothstep(0.6, 0.15, brightness);  // Very gradual
    
    // At night, make sky fully fogged
    float skyEnd = mix(FogSkyEnd, 3.0, nightFactor);  // Fog the sky at night
    
    // Use cylindrical distance for tall fog
    float fogDistance = mix(sphericalVertexDistance, cylindricalVertexDistance, nightFactor);
    
    fragColor = apply_fog(ColorModulator, fogDistance, fogDistance, 0.0, skyEnd, skyEnd, skyEnd, FogColor);
}