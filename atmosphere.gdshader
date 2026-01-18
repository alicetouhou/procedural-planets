shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform vec3 planet_position;
uniform float planet_radius;
uniform vec3 sun_position;
uniform float atmosphere_size;

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

//https://iquilezles.org/articles/distfunctions/
float sdSphere(vec3 p, float s )
{
  return length(p)-s;
}

//sdf world
float map(vec3 pos) {
	float d = length(pos)-planet_radius*(1. + atmosphere_size);
	return d;
}

vec3 get_normal(vec3 p) {
	vec2 e = vec2(1e-3, 0);
	
	vec3 n = map(p) - vec3(
		map(p - e.xyy),
		map(p - e.yxy),
		map(p - e.yyx)
	);
	
	return normalize(n);
}

vec4 raymarch(vec3 ro, vec3 rd) {
	float t = 0.0;
	vec3 pos = ro;
	for (int i=0; i<300; i++) {
		pos += t*rd;
		float h = map(pos);
		if (h < 0.001) {
			break;
		}
		t += h;
		if (t>1000.0) break;
	}
	if (t < 30.0) {
		return vec4(get_normal(pos),1);
	}
	return vec4(0.0);
}

void fragment() {
	//https://godotshaders.com/shader/simple-fullscreen-raymarching/
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
    vec4 camera = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1);
	
	vec3 ro = INV_VIEW_MATRIX[3].xyz;
	vec3 rd = normalize(camera.xyz);	
	
	vec4 world = raymarch(ro, rd);


	ALBEDO = dot(normalize(world.rgb),normalize(sun_position)) * vec3(0.2,0.4,1.0);
	ALPHA = world.a;
}