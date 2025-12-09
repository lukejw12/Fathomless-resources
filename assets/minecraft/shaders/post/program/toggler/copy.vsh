#version 150

uniform mat4 ProjMat;
uniform vec2 OutSize;

out vec2 texCoord;

void main() {
    float x = float((gl_VertexID & 1) << 2);
    float y = float((gl_VertexID & 2) << 1);
    
    gl_Position = ProjMat * vec4(x - 1.0, y - 1.0, 0.0, 1.0);
    texCoord = vec2(x, y) * 0.5;
}