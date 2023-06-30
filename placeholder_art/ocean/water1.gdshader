shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx, world_vertex_coords;
uniform vec4 albedo : source_color;
uniform float specular;
uniform float metallic;
uniform float near_roughness = 0.0;
uniform float far_roughness = 0.7;
uniform float near_range = 25.0;
uniform float middle_range = 75.0;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale;// : hint_range(-16,16);
uniform float world_scale = 1.0;

varying vec3 pos;

void vertex() {
	pos = VERTEX;
	
}

vec2 rotate_vec(vec2 vec, float rotation) {
    float sine = sin(rotation);
    float cosine = cos(rotation);

    vec.x = vec.x * cosine - vec.y * sine;
    vec.y = vec.x * sine + vec.y * cosine;

    return vec;
}

vec3 texture_waves(sampler2D tex, vec2 base_pos, float time){
	vec3 samplesum = vec3(0.0);
	vec2 direction = vec2(0.1, 0.9);
	samplesum += texture(tex, base_pos + vec2(0.729423, -0.536603)*time).rgb*0.5;//vec2(0.1, 0.9)
	samplesum += texture(tex, base_pos + vec2(-0.829423, -0.363398)*time).rgb*0.5;
	//samplesum += texture(tex, base_pos + vec2(0.729423, -0.536603)*time).rgb*0.25;
	return samplesum;
}

void fragment() {
	vec2 base_uv = pos.xz/world_scale / 1.0;
	float time = TIME / 250.0 / world_scale;
	vec3 normala = texture_waves(texture_normal,base_uv*0.005, time);
	vec3 near_normal = (normala + texture_waves(texture_normal,(base_uv+normala.xy)*0.02, time)) * 0.5;
	
	float dist = length(VERTEX)/world_scale;
	
	
	float nearfac = clamp((dist - near_range)/(middle_range - near_range), 0.0, 1.0);
	
	ALBEDO = albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = near_roughness;
	SPECULAR = specular;
	NORMAL_MAP = near_normal;
	NORMAL_MAP_DEPTH = mix(5.0, 0.0, nearfac);
}
