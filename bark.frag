varying vec4  Color;
varying float LightIntensity;
varying vec2  vST;

varying vec3  vMCposition;

uniform bool uUseST;
uniform float Size;

uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

void main()
{	
	float s;
	float t;
	
	vec4  nv  = texture3D( Noise3, uNoiseFreq * vMCposition );
	float n = nv.r + nv.g + nv.b + nv.a;	// 1. -> 3.
	n = ( n - 2. );				// -1. -> 1.
	float delta = uNoiseMag * n;

	s = vST.s;
	t = vST.t;

	t/=3.5;
	
	s+= delta;
	t+= delta/3.;
	
	float numins = floor( s / Size );
	float numint = floor( t / Size );

	gl_FragColor = Color;		// default color
	
	//Cracks
	if(mod(s/Size, 2.0) < .15 || mod(t/Size, 2.0) < .08)
		gl_FragColor = vec4(Color.rgb*.25, 1.0);
	
	//if( mod( numins+numint, 2. ) == 0. )
	//{
	//	gl_FragColor = vec4( 1., 1., 1., 1. );
	//}

	gl_FragColor.rgb *= LightIntensity;	// apply lighting model
}
