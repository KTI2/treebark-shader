#version 330 compatibility
#extension GL_EXT_geometry_shader4: enable

layout(triangles)  in;
layout(triangle_strip, max_vertices=3)  out;

out vec3 geoNorm;

void main( )
{
	//Point 1
    vec3 p1 = gl_PositionIn[1].xyz - gl_PositionIn[0].xyz;
    vec3 p2 = gl_PositionIn[2].xyz - gl_PositionIn[0].xyz;
	
    geoNorm = normalize(cross(p1,p2));
	geoNorm = gl_NormalMatrix * geoNorm;
	
	gl_Position = gl_PositionIn[0];
	EmitVertex();
	
	//Point 2
    p1 = gl_PositionIn[2].xyz - gl_PositionIn[1].xyz;
    p2 = gl_PositionIn[0].xyz - gl_PositionIn[1].xyz;
	
    geoNorm = normalize(cross(p1,p2));
	geoNorm = gl_NormalMatrix * geoNorm;
	
	gl_Position = gl_PositionIn[1];
	EmitVertex();
	
	//Point 3
    p1 = gl_PositionIn[0].xyz - gl_PositionIn[2].xyz;
    p2 = gl_PositionIn[1].xyz - gl_PositionIn[2].xyz;
	
    geoNorm = normalize(cross(p1,p2));
	geoNorm = gl_NormalMatrix * geoNorm;
	
	gl_Position = gl_PositionIn[2];
	EmitVertex();

    EndPrimitive();
}
