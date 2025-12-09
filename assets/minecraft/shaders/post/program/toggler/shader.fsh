#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ControlSampler;
uniform sampler2D DiffuseDepthSampler;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0);
    
    bool headlight_on = control_color.b > 0.001 && control_color.b < 0.1;
    
    if (headlight_on) {
        float depth = texture(DiffuseDepthSampler, texCoord).r;
        
        float near = 0.05;
        float far = 1024.0;
        float linear_depth = (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
        
        vec2 ndc = texCoord * 2.0 - 1.0;
        float fov_factor = length(vec2(ndc.x, ndc.y * (9.0/16.0))) * 0.5 + 1.0;
        float distance = linear_depth * fov_factor;
        
        float cone_radius = 0.3;
        float center_dist = length(ndc);
        float cone_factor = smoothstep(cone_radius + 0.2, cone_radius - 0.1, center_dist);
        
        float range_factor = smoothstep(40.0, 2.0, distance);
        
        float headlight_strength = cone_factor * range_factor * 0.8;
        
        color.rgb = mix(color.rgb, color.rgb * 1.5 + vec3(0.2, 0.2, 0.0), headlight_strength);
    }
    
    fragColor = color;
}