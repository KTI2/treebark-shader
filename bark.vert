varying vec4  Color;
varying float LightIntensity;
varying vec2  vST;
varying vec3 vMCposition;

const vec3 LIGHTPOS = vec3( 0., 0., 10. );
const vec3 barkColor = vec3(.529, .208, 0);

//Noise
uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

void main()
{
	vec3 tnorm = normalize( vec3( gl_NormalMatrix * gl_Normal ) );
	vec3 ECposition = vec3( gl_ModelViewMatrix * gl_Vertex );
	LightIntensity  = abs( dot( normalize(LIGHTPOS - ECposition), tnorm )  );

	vST = gl_MultiTexCoord0.st;
	vMCposition = gl_Vertex.xyz;
	
	//Noise
	vec4  nv  = texture3D( Noise3, uNoiseFreq * vMCposition );
	float n = nv.r + nv.g + nv.b + nv.a;	// 1. -> 3.
	n = ( n - 2. );				// -1. -> 1.
	float delta = uNoiseMag * n;
	
	Color = vec4(barkColor, 1.0);
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
