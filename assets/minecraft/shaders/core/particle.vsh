#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;
flat out float isMarker;
flat out vec4 tint;
out vec3 worldPos;
out vec3 viewDirection;

vec2[] corners = vec2[](
    vec2(0, 1),
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1)
);

const float minGreen = 252.0;
const float maxGreen = 253.0;

void main() {
    tint = Color;
    
    if (abs(Color.r * 255. - 254.) < 0.5 && Color.g * 255. > minGreen - 0.5 && Color.g * 255. < maxGreen + 0.5) {
        isMarker = 1.0;
        vec2 screenPos = 0.125 * corners[gl_VertexID % 4] - 1.0;
        gl_Position = vec4(screenPos, 0.0, 1.0);
        sphericalVertexDistance = 0.0;
        cylindricalVertexDistance = 0.0;
        texCoord0 = vec2(0);
        vertexColor = vec4(0);
        worldPos = vec3(0);
        viewDirection = vec3(0);
    } else {
        isMarker = 0.0;
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

        sphericalVertexDistance = fog_spherical_distance(Position);
        cylindricalVertexDistance = fog_cylindrical_distance(Position);
        texCoord0 = UV0;
        vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
        
        worldPos = Position;
        viewDirection = normalize((inverse(ModelViewMat) * vec4(0.0, 0.0, -1.0, 0.0)).xyz);
    }
}