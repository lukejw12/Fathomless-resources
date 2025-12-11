#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ControlSampler;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0);
    bool headlight_on = control_color.b < 0.1;
    
    if (headlight_on) {
        vec2 ndc = texCoord * 2.0 - 1.0;
        float dist = length(ndc);
        float cone = smoothstep(0.7, 0.0, dist);
        
        if (cone > 0.01) {
            float gray = (color.r + color.g + color.b) / 3.0;
            float colorVariance = abs(color.r - gray) + abs(color.g - gray) + abs(color.b - gray);
            float fogginess = (1.0 - colorVariance * 3.0) * smoothstep(0.05, 0.5, gray) * smoothstep(0.9, 0.4, gray);
            fogginess = clamp(fogginess, 0.0, 1.0);
            
vec3 brightened = color.rgb * (1.0 + cone * 0.35) + vec3(0.1, 0.1, 0.03) * cone;
vec3 fog_cleared = color.rgb * (1.0 + cone * 3.5) + vec3(0.35, 0.35, 0.15) * cone;
            
            color.rgb = mix(brightened, fog_cleared, fogginess);
        }
    }
    
    fragColor = color;
}