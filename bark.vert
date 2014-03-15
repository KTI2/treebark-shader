varying vec4  Color;
varying float LightIntensity;
varying vec2  vST;
varying vec3	vMCposition;

const vec3 LIGHTPOS = vec3( 0., 0., 10. );
const vec3 barkColor = vec3(.529, .208, 0);

uniform float Size;

//Noise
uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

void main()
{
	Color = vec4(barkColor, 1.0);

	vST = gl_MultiTexCoord0.st;
	vMCposition = gl_Vertex.xyz;
	
	//Noise
	vec4  nv  = texture3D( Noise3, uNoiseFreq * vMCposition );
	float n = nv.r + nv.g + nv.b + nv.a;	// 1. -> 3.
	n = ( n - 2. );				// -1. -> 1.
	float delta = uNoiseMag * n;
	
	//Displacement
	float s;
	float t;

	s = vST.s;
	t = vST.t;

	t/=3.5;
	
	s+= delta;
	t+= delta/3.;
	
	vec4 pos = gl_Vertex;
	vec3 tnorm = normalize( vec3( gl_NormalMatrix * gl_Normal ) );
	
	//Bark chunks (anti cracks)
	if(mod(s/Size, 2.0) >= .14 && mod(t/Size, 2.0) >= .07)
	{
		pos= vec4(pos.xyz + gl_Normal*.1, 1.0);
		tnorm = gl_Normal +(normalize(gl_Normal)*.1, 1.0);
	}
	
	//Lighting
	vec3 ECposition = vec3( gl_ModelViewMatrix * pos );
	LightIntensity  = abs( dot( normalize(LIGHTPOS - ECposition), tnorm )  );
	
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}
