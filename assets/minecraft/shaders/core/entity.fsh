#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
#ifdef PER_FACE_LIGHTING
    color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
#else
    color *= vertexColor * ColorModulator;
#endif
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    
    // Detect night by fog color brightness
    // Smoother night detection (gradual transition as sun sets)
float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
float nightFactor = smoothstep(0.6, 0.15, brightness);  // Very gradual
    
    // Adjust fog for night - denser and taller
    float envStart = mix(FogEnvironmentalStart, 5.0, nightFactor);
    float envEnd = mix(FogEnvironmentalEnd, 10.0, nightFactor);
    
    // Use cylindrical distance to make fog "taller"
    float fogDistance = mix(sphericalVertexDistance, cylindricalVertexDistance, nightFactor);
    
    fragColor = apply_fog(color, fogDistance, fogDistance, envStart, envEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}