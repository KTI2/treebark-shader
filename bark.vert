varying vec4  Color;
varying float LightIntensity;
varying vec2  vST;
varying vec3	vMCposition;

//Lighting
uniform float uLightX, uLightY, uLightZ;
uniform float uKa, uKd, uKs;
uniform vec4  uSpecularColor;

varying float uShininess;

varying vec3 vNs;
varying vec3 vLs;
varying vec3 vEs;

varying vec3 vPVs;

varying vec4 barkColor;

uniform float Size;

//Noise
uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

void main()
{
	barkColor = vec4(.529, .208, 0, 1.0);
	uShininess = .5;
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
	if(mod(s/Size, 2.0) >= .14 && mod(t/Size, 2.0) >= .07)
	{
		pos= vec4(pos.xyz + gl_Normal*.1, 1.0);
		tnorm = normalize(gl_Normal +(normalize(gl_Normal)*.1, 1.0));
	}
	
	//Lighting
	vec3 ECposition = vec3( gl_ModelViewMatrix * pos );
	
	vec3 eyeLightPosition = vec3( uLightX, uLightY, uLightZ );
	
	vNs = tnorm;
	vLs = eyeLightPosition - ECposition.xyz;		// vector from the point
	vEs = vec3( 0., 0., 0. ) - ECposition.xyz;		// vector from the point
	
	vec3 Normal = normalize(vNs);
	vec3 Light =  normalize(vLs);
	vec3 Eye =    normalize(vEs);

	vec4 ambient = uKa * Color;
	
	float d = max( dot(Normal,Light), 0. );
	vec4 diffuse = uKd * d * Color;

	float sLight = 0.;
	
	if( dot(Normal,Light) > 0. )		// only do specular if the light can see the point
	{
		vec3 ref = normalize( 2. * Normal * dot(Normal,Light) - Light );
		sLight = pow( max( dot(Eye,ref),0. ), uShininess );
	}
	
	vec4 specular = uKs * sLight * uSpecularColor;

	vPVs = ambient.rgb + diffuse.rgb + specular.rgb;
	
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}
