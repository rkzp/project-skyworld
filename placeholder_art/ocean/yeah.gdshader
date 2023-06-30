shader_type spatial;
render_mode cull_disabled, shadows_disabled, skip_vertex_transform;

uniform vec3 water_color : source_color;
uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D screen_texture : source_color, hint_screen_texture;

void vertex(){
	if (COLOR.b > 0.5){
		NORMAL = vec3(0.0, 1.0, 0.0);
		TANGENT = vec3(1.0, 0.0, 0.0);
		BINORMAL = vec3(0.0, 0.0, 1.0);
		POSITION = vec4(VERTEX.xy, 0.99999, 1.0);
		VERTEX = (INV_PROJECTION_MATRIX * POSITION).xyz;
	}else{
		VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
		TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
		BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
		POSITION = PROJECTION_MATRIX * vec4(VERTEX.xyz, 1.0);
	}
}

void fragment() {
	if (COLOR.b > 0.5){
		vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, 0.99999, 1.0);
		if (normalize((INV_VIEW_MATRIX * vec4(normalize(view.xyz / view.w), 0.0)).xyz).y <= 0.0){
			ALBEDO = water_color;
		} else discard;
	}else{
		
	}
}
