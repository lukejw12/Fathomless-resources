#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec3 worldPos;
in vec3 viewDirection;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    
    float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
    bool turningOn = brightness < 0.031;
    bool turningOff = brightness > 0.035;
    bool hasWither = turningOn || (!turningOff && brightness < 0.038);
    
    float nightFactor = smoothstep(0.6, 0.15, brightness);
    
    float envStart = mix(FogEnvironmentalStart, 4.0, nightFactor);
    float envEnd = mix(FogEnvironmentalEnd, 7.0, nightFactor);
    
    if (hasWither && nightFactor > 0.2) {
        vec3 forward = vec3(viewDirection.x, 0.0, viewDirection.z);
        forward = normalize(forward);
        forward.y = -0.15;
        forward = normalize(forward);
        
        vec3 adjustedWorldPos = worldPos;
        adjustedWorldPos.y = 0.0;
        
        float alongBeam = dot(adjustedWorldPos, forward) + 2.0;
        
        if (alongBeam > 0.0) {
    vec3 toFragment = normalize(adjustedWorldPos);
    float angleFromBeam = acos(clamp(dot(toFragment, forward), -1.0, 1.0));
    
    float beamLength = 17.0;
    
    float baseConeAngle = radians(5.0);
    float endConeAngle = radians(15.0);
    float progress = clamp(alongBeam / beamLength, 0.0, 1.0);
    float coneAngle = mix(baseConeAngle, endConeAngle, progress);
    
    float fadeIn = smoothstep(0.0, 1.0, alongBeam);
    
float fadeOut = smoothstep(beamLength + 20.0, beamLength - 10.0, alongBeam);
    
    float beamStrength = smoothstep(coneAngle + radians(0.5), coneAngle - radians(0.5), angleFromBeam) * 
                        fadeIn * fadeOut;
    
envStart = mix(envStart, 60.0, beamStrength);
envEnd = mix(envEnd, 100.0, beamStrength);
}
    }
    
    fragColor = apply_fog(color, cylindricalVertexDistance, cylindricalVertexDistance, envStart, envEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}