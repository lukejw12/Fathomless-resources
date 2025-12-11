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
in vec3 worldPos;
in vec3 viewDirection;

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
    
    float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
    bool turningOn = brightness < 0.031;
    bool turningOff = brightness > 0.035;
    bool hasWither = turningOn || (!turningOff && brightness < 0.038);
    
    float nightFactor = smoothstep(0.6, 0.15, brightness);
    
    float envStart = mix(FogEnvironmentalStart, 6.0, nightFactor);
    float envEnd = mix(FogEnvironmentalEnd, 7.0, nightFactor);
    
    if (hasWither && nightFactor > 0.2) {
        vec3 forward = viewDirection;
        forward.y = -0.15;
        forward = normalize(forward);
        
        float alongBeam = max(dot(worldPos, forward), 0.0);
        vec3 toFragment = normalize(worldPos);
        float angleFromBeam = acos(clamp(dot(toFragment, forward), -1.0, 1.0));
        
        float beamLength = 25.0;
        
        float baseConeAngle = radians(5.0);
        float endConeAngle = radians(15.0);
        float progress = clamp(alongBeam / beamLength, 0.0, 1.0);
        float coneAngle = mix(baseConeAngle, endConeAngle, progress);
        
        float beamStrength = smoothstep(coneAngle + radians(3.0), coneAngle, angleFromBeam) * 
                            smoothstep(beamLength + 2.0, 0.0, alongBeam);
        
        envStart = mix(envStart, 800.0, beamStrength);
        envEnd = mix(envEnd, 1200.0, beamStrength);
    }
    
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, envStart, envEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}