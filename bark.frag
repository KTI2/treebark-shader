varying vec2  vST;

//Light
uniform float uKa, uKd, uKs;
uniform vec4  uColor;
uniform vec4  uSpecularColor;

varying float uShininess;
varying vec3  vMCposition;

varying vec3 vNs;
varying vec3 vLs;
varying vec3 vEs;

varying vec3 vPVs;

uniform float Size;

uniform float uNoiseMag;
uniform float uNoiseFreq;
uniform sampler3D Noise3;

const vec4 barkColor = vec4(.722, .506, .275, 1.0);
uniform float barkShade;

void main()
{	
	vec4 Color = vec4(barkColor.rgb*barkShade, 1.0);
	
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
	
	//Color variation
	Color = vec4(Color.r+delta*4., Color.g+delta*4., Color.b+delta*4., 1.0);
	
	float numins = floor( s / Size );
	float numint = floor( t / Size );
	
	if(mod(numins, 2.0) == 0.)
		t+= Size;
	
	//Cracks
	if(mod(s/Size, 2.0) < .15 || mod(t/Size, 2.0) < .08)
	{
		Color = vec4(Color.rgb*.25, 1.0);
	}
	
	//Lighting
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

	gl_FragColor = vec4( ambient.rgb + diffuse.rgb + specular.rgb, 1. );
	//gl_FragColor.rgb *= LightIntensity;	// apply lighting model
}
