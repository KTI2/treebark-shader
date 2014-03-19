#version 330 compatibility

uniform float uLightX, uLightY, uLightZ;
uniform float Size;

out vec3 vLs;
out vec3 vEs;

out vec3 vMCposition;
out float height;

//Noise
uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;


void main()
{
	vMCposition = gl_Vertex.xyz;
	
	//Noise
	vec4  nv  = texture3D( Noise3, uNoiseFreq * vMCposition );
	float n = nv.r + nv.g + nv.b + nv.a;	// 1. -> 3.
	n = ( n - 2. );				// -1. -> 1.
	float delta = uNoiseMag * n;
	
	vec4 pos = gl_Vertex;
	
	//Displacement
	float s = gl_MultiTexCoord0.s;
	float t = gl_MultiTexCoord0.t;

	t/=3.5;
	
	s+= delta;
	t+= delta/3.;
	
	//Offset Cracks a bit
	float numins = floor( s / Size );
	float numint = floor( t / Size );
	
	if(mod(numins, 2.0) == 0.)
		t+= Size;
	
	//Bark chunks (anti cracks)
	height = .1+(delta*2.);
	
	float fracts = mod(s/Size, 2.0);
	float fractt = mod(t/Size, 2.0);
	
	if(fracts >= .14 && fractt >= .07)
	{
		pos= vec4(gl_Vertex.xyz + gl_Normal*height, 1.0);
		
		//Ramp
		if(fracts < .45 || fractt < .24)
		{
			//Convert to coefficient for blending
			fracts-= .14;
			fractt-= .07;
			fracts*= 3.226;
			fractt*= 5.883;
			
			if(fracts > fractt)
			{
				pos= vec4(gl_Vertex.xyz + gl_Normal*height*fractt, 1.0);
			} else {
				pos= vec4(gl_Vertex.xyz + gl_Normal*height*fracts, 1.0);
			}
		}
	}
	
	//Lighting
	vec4 ECposition = gl_ModelViewMatrix * pos;
	
	vec3 eyeLightPosition = vec3( uLightX, uLightY, uLightZ );
	
	vLs = eyeLightPosition - ECposition.xyz;
	vEs = vec3( 0., 0., 0. ) - ECposition.xyz;
	
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}
