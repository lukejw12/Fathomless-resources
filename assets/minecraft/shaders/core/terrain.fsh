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
    
    // Check if we're rendering the block at (0, 0, 0)
    // If worldPos is close to origin AND has magenta color, headlight is ON
    float distToOrigin = length(worldPos);
    bool isAtOrigin = distToOrigin < 1.0;
    
    // Check if color is magenta (R≈1, B≈1, G≈0.5-0.8)
    bool isMagenta = vertexColor.r > 0.8 && vertexColor.b > 0.8 && vertexColor.g > 0.4 && vertexColor.g < 0.9;
    
    float headlightOn = (isAtOrigin && isMagenta) ? 1.0 : 0.0;
    
    // Smoother night detection
    float brightness = (FogColor.r + FogColor.g + FogColor.b) / 3.0;
    float nightFactor = smoothstep(0.6, 0.15, brightness);
    
    // Base fog
    float envStart = mix(FogEnvironmentalStart, 5.0, nightFactor);
    float envEnd = mix(FogEnvironmentalEnd, 10.0, nightFactor);
    
    if (headlightOn > 0.5) {
        vec3 forward = normalize(viewDirection);
        vec3 rightDir = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
        
        vec3 leftSpotPos = rightDir * -0.5;
        vec3 rightSpotPos = rightDir * 0.5;
        
        vec3 toFragmentLeft = worldPos - leftSpotPos;
        vec3 toFragmentRight = worldPos - rightSpotPos;
        
        float alongBeamLeft = dot(toFragmentLeft, forward);
        float alongBeamRight = dot(toFragmentRight, forward);
        
        vec3 projectionLeft = leftSpotPos + forward * alongBeamLeft;
        vec3 projectionRight = rightSpotPos + forward * alongBeamRight;
        
        float distFromBeamLeft = length(worldPos - projectionLeft);
        float distFromBeamRight = length(worldPos - projectionRight);
        
        float startRadius = 0.5;
        float coneAngle = 0.08;
        
        float beamRadiusLeft = startRadius + alongBeamLeft * coneAngle;
        float beamRadiusRight = startRadius + alongBeamRight * coneAngle;
        
        float leftBeam = (alongBeamLeft > 0.0) ? smoothstep(beamRadiusLeft + 2.0, beamRadiusLeft - 1.0, distFromBeamLeft) : 0.0;
        float rightBeam = (alongBeamRight > 0.0) ? smoothstep(beamRadiusRight + 2.0, beamRadiusRight - 1.0, distFromBeamRight) : 0.0;
        
        float maxRange = 25.0;
        float falloffLeft = smoothstep(maxRange, 0.0, alongBeamLeft);
        float falloffRight = smoothstep(maxRange, 0.0, alongBeamRight);
        
        leftBeam *= falloffLeft;
        rightBeam *= falloffRight;
        
        float headlightIntensity = max(leftBeam, rightBeam);
        
        envStart = mix(envStart, 15.0, headlightIntensity);
        envEnd = mix(envEnd, 25.0, headlightIntensity);
    }
    
    fragColor = apply_fog(color, cylindricalVertexDistance, cylindricalVertexDistance, envStart, envEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}