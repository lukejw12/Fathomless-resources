#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ParticleSampler;

layout(std140) uniform Globals {
    vec2 ScreenSize;
    float GlintAlpha;
    float GameTime;
    int MenuBlurRadius;
};

in vec2 texCoord;
out vec4 fragColor;

void readMarker(inout vec4 fragColor, vec4 lastValue, ivec2 markerPos, vec2 markerColor, int row) {
    if (int(gl_FragCoord.x) == 0) {
        vec4 marker = texelFetch(ParticleSampler, markerPos, 0);
        if (abs(marker.r * 255.0 - markerColor.x) < 0.5 && abs(marker.g * 255.0 - markerColor.y) < 0.5) {
            fragColor = marker;
        }
    } else {
        vec4 target = texelFetch(DiffuseSampler, ivec2(0, row), 0);
        fragColor = lastValue + sign(target - lastValue)/255.0;
    }
}

void main() {
    vec4 lastValue = texture(DiffuseSampler, texCoord);
    fragColor = lastValue;
    
    switch (int(gl_FragCoord.y)) {
        case 0:
            float time1 = lastValue.y + (floor(lastValue.x*255.0) > ceil(GameTime*255.0) ? 1.0/255.0 : 0.0);
            float time2 = lastValue.z + floor(time1)/255.0;
            fragColor = vec4(GameTime, fract(time1), fract(time2), 1.0);
            break;
        case 1:
            readMarker(fragColor, lastValue, ivec2(0, 0), vec2(254.0, 253.0), 1);
            break;
        case 2:
            readMarker(fragColor, lastValue, ivec2(0, 2), vec2(254.0, 252.0), 2);
            break;
    }
}