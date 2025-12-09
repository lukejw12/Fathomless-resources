#version 150

uniform sampler2D DiffuseSampler;
uniform vec2 InSize;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec4 color = texture(DiffuseSampler, texCoord);
    
    // Check button position (101px from right, 88px from bottom)
    vec2 buttonPos = vec2(InSize.x - 101.0, InSize.y - 88.0);
    vec2 currentPos = gl_FragCoord.xy;
    
    // If we're at the bottom-left corner (0,0), write the signal
    if (currentPos.x < 1.0 && currentPos.y < 1.0) {
        // Sample the button location
        vec2 buttonUV = buttonPos / InSize;
        vec4 buttonPixel = texture(DiffuseSampler, buttonUV);
        
        // Check for gray #414141
        float grayValue = 65.0 / 255.0;
        float tolerance = 0.03;
        
        bool isGray = abs(buttonPixel.r - grayValue) < tolerance && 
                      abs(buttonPixel.g - grayValue) < tolerance && 
                      abs(buttonPixel.b - grayValue) < tolerance;
        
        // Write signal: magenta if detected, black if not
        fragColor = isGray ? vec4(1.0, 0.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        fragColor = color;
    }
}