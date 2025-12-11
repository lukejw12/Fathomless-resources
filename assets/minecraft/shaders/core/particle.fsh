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
in vec3 worldPos;
in vec3 viewDirection;

out vec4 fragColor;

void main() {
    if (isMarker > 0.5) {
        ivec2 iCoord = ivec2(gl_FragCoord.xy);
        
        if (abs(tint.g * 255.0 - 253.0) < 0.5 && iCoord == ivec2(0, 0)) {
            fragColor = vec4(254.0/255.0, tint.gb, 1.0);
        } else if (abs(tint.g * 255.0 - 252.0) < 0.5 && iCoord == ivec2(0, 2)) {
            fragColor = vec4(254.0/255.0, tint.gb, 1.0);
        } else {
            discard;
        }
    } else {
        vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
        if (color.a < 0.1) {
            discard;
        }
        
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
}