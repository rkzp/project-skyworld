shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform float specular;
uniform float metallic;
uniform float near_roughness = 0.0;
uniform float far_roughness = 0.7;
uniform float near_range = 25.0;
uniform float middle_range = 75.0;
uniform sampler2D texture_depth : hint_default_black;
uniform float normal_scale;// : hint_range(-16,16);
uniform float world_scale = 1.0;
uniform float ocean_size = 10000.0;
uniform float displacement_scale = 0.2;

varying vec3 pos;

vec2 depth_to_normal(sampler2D depth_texture, vec2 uv, float uvoffset){
	/*float center_sample = texture(depth_texture, uv).x;
	vec3 normalpre = vec3(0.0);
	normalpre -= vec3(0.5, 0.5, 1.0) * (center_sample - texture(depth_texture, uv + vec2(0.707, 0.707) * uvoffset).x);
	normalpre -= vec3(0.5, -0.5, 1.0) * (center_sample - texture(depth_texture, uv + vec2(0.707, -0.707) * uvoffset).x);
	normalpre -= vec3(-0.5, -0.5, 1.0) * (center_sample - texture(depth_texture, uv + vec2(-0.707, -0.707) * uvoffset).x);
	normalpre -= vec3(-0.5, 0.5, 1.0) * (center_sample - texture(depth_texture, uv + vec2(-0.707, 0.707) * uvoffset).x);*/
	vec2 normal = vec2(0.0);
	normal.x = (texture(depth_texture, uv - vec2(uvoffset, 0.0)).x - texture(depth_texture, uv + vec2(uvoffset, 0.0)).x);
	normal.y = -(texture(depth_texture, uv - vec2(0.0, uvoffset)).x - texture(depth_texture, uv + vec2(0.0, uvoffset)).x);
	
	
	return normalize(vec3(normal, 1.0)).xy * 0.5 + 0.5;
}

void vertex() {
	float prevertex = pow(length(VERTEX), 2.0);
	//VERTEX.xz *= prevertex;
	//VERTEX *= ocean_size;
	pos = VERTEX;
	
}

void fragment() {
	vec2 base_uv = pos.xz * 0.01;
	float time = TIME * 0.05;
	
	vec2 normal_sample_1 = depth_to_normal(texture_depth, base_uv + vec2(time, time) * 0.1, 0.1);
	vec2 normal_sample_2 = depth_to_normal(texture_depth, base_uv * 2.0 + vec2(time, -time) * 0.25 - normal_sample_1 * 0.05, 0.01);
	
	float nearfac = 0.0;//clamp((dist - near_range)/(middle_range - near_range), 0.0, 1.0);
	
	ALBEDO = albedo.rgb;// * (1.0 + pos.y);
	METALLIC = metallic;
	ROUGHNESS = near_roughness;
	SPECULAR = specular;
	NORMAL_MAP.xy = mix(normal_sample_1, normal_sample_2, 0.75);
	NORMAL_MAP_DEPTH = 0.15;
}
