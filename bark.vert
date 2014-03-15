//Lighting
uniform float uLightX, uLightY, uLightZ;
uniform float uKa, uKd, uKs;
uniform vec4  uSpecularColor;

varying float uShininess;

varying vec3 vNs;
varying vec3 vLs;
varying vec3 vEs;
varying vec3 vPVs;

//Noise
uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

//Mine
varying vec4 	Color;
varying vec2  	vST;
varying vec3	vMCposition;

varying vec4 barkColor;
uniform float Size;

void main()
{
	barkColor = vec4(.529, .208, 0, 1.0);
	uShininess = .1;
	Color = vec4(barkColor);

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
	float height = .1+(delta*2.);
	
	float fracts = mod(s/Size, 2.0);
	float fractt = mod(t/Size, 2.0);
	
	if(fracts >= .14 && fractt >= .07)
	{
		pos= vec4(gl_Vertex.xyz + gl_Normal*height, 1.0);
		//tnorm = normalize(gl_Normal + gl_Normal*height);
		
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
	vec3 ECposition = vec3( gl_ModelViewMatrix * pos );
	
	vec3 eyeLightPosition = vec3( uLightX, uLightY, uLightZ );
	
	vNs = tnorm;
	vLs = eyeLightPosition - ECposition.xyz;		// vector from the point
	vEs = vec3( 0., 0., 0. ) - ECposition.xyz;		// vector from the point
	
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}
