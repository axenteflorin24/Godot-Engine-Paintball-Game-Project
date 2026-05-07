shader_type spatial;
render_mode cull_disabled;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform vec4 albedo_b : source_color;
uniform sampler2D texture_albedo_b : source_color;


uniform sampler2D texture_alpha : source_color;



uniform float uv_scale_x=1;
uniform float uv_scale_y=1;


uniform float uv_scale_x_b=1;
uniform float uv_scale_y_b=1;
uniform float offset_amount = 0.01;


uniform float rot_strength : hint_range(0.0, 1.0) = 0.5;

/* 
	Restores the contrast that naturally gets lost when blending 3 texture samples.
	0.50 = No contrast adjustment (will look blurry).
	0.75 = Recommended by the author. Restores crispness without revealing the grid.
	0.99 = Max contrast (Warning: May make the hexagonal grid borders visible).
*/
uniform float contrast_adjust : hint_range(0.01, 0.99) = 0.75;


void TriangleGrid(out float w1, out float w2, out float w3,
	out ivec2 vertex1, out ivec2 vertex2, out ivec2 vertex3,
	vec2 st) {

	// Scaling of the input
	st *= 2.0 * sqrt(3.0);

	/* 
		Skew input space into simplex triangle grid.
		Note: GLSL mat2 is column-major, so this is transposed from HLSL.
	*/
	mat2 gridToSkewedGrid = mat2(vec2(1.0, 0.0), vec2(-0.57735027, 1.15470054));
	vec2 skewedCoord = gridToSkewedGrid * st;

	ivec2 baseId = ivec2(floor(skewedCoord));
	vec3 temp = vec3(fract(skewedCoord), 0.0);
	temp.z = 1.0 - temp.x - temp.y;

	float s = step(0.0, -temp.z);
	float s2 = 2.0 * s - 1.0;

	w1 = -temp.z * s2;
	w2 = s - temp.y * s2;
	w3 = s - temp.x * s2;

	vertex1 = baseId + ivec2(int(s), int(s));
	vertex2 = baseId + ivec2(int(s), int(1.0 - s));
	vertex3 = baseId + ivec2(int(1.0 - s), int(s));
}

vec2 hash(vec2 p) {
	mat2 m = mat2(vec2(127.1, 269.5), vec2(311.7, 183.3));
	vec2 r = m * p;
	return fract(sin(r) * 43758.5453);
}

vec2 MakeCenST(ivec2 Vertex) {
	mat2 invSkewMat = mat2(vec2(1.0, 0.0), vec2(0.5, 1.0 / 1.15470054));
	return (invSkewMat * vec2(Vertex)) / (2.0 * sqrt(3.0));
}

mat2 LoadRot2x2(ivec2 idx, float rotStrength) {
	float angle = abs(float(idx.x * idx.y)) + abs(float(idx.x + idx.y)) + PI;

	// Remap to +/-pi.
	angle = mod(angle, 2.0 * PI);
	if(angle < 0.0) angle += 2.0 * PI;
	if(angle > PI) angle -= 2.0 * PI;

	angle *= rotStrength;

	float cs = cos(angle);
	float si = sin(angle);

	return mat2(vec2(cs, si), vec2(-si, cs));
}

vec3 Gain3(vec3 x, float r) {
	// Increase contrast when r > 0.5 and reduce contrast if less.
	float k = log(1.0 - r) / log(0.5);
	vec3 s = 2.0 * step(vec3(0.5), x);
	vec3 m = 2.0 * (1.0 - s);

	vec3 res = 0.5 * s + 0.25 * m * pow(max(vec3(0.0), s + x * m), vec3(k));
	return res / (res.x + res.y + res.z);
}

vec4 hex2colTex(sampler2D tex, vec2 st, float rotStrength, float r) {
	// Calculate derivatives for mipmapping *before* manipulating UVs
	vec2 dSTdx = dFdx(st);
	vec2 dSTdy = dFdy(st);

	// Get triangle info.
	float w1, w2, w3;
	ivec2 vertex1, vertex2, vertex3;
	TriangleGrid(w1, w2, w3, vertex1, vertex2, vertex3, st);

	mat2 rot1 = LoadRot2x2(vertex1, rotStrength);
	mat2 rot2 = LoadRot2x2(vertex2, rotStrength);
	mat2 rot3 = LoadRot2x2(vertex3, rotStrength);

	vec2 cen1 = MakeCenST(vertex1);
	vec2 cen2 = MakeCenST(vertex2);
	vec2 cen3 = MakeCenST(vertex3);

	vec2 st1 = (rot1 * (st - cen1)) + cen1 + hash(vec2(vertex1));
	vec2 st2 = (rot2 * (st - cen2)) + cen2 + hash(vec2(vertex2));
	vec2 st3 = (rot3 * (st - cen3)) + cen3 + hash(vec2(vertex3));

	// Fetch input textures using explicit derivatives to prevent seam artifacts
	vec4 c1 = textureGrad(tex, st1, rot1 * dSTdx, rot1 * dSTdy);
	vec4 c2 = textureGrad(tex, st2, rot2 * dSTdx, rot2 * dSTdy);
	vec4 c3 = textureGrad(tex, st3, rot3 * dSTdx, rot3 * dSTdy);

	// Use luminance as weight.
	vec3 Lw = vec3(0.299, 0.587, 0.114);
	vec3 Dw = vec3(dot(c1.rgb, Lw), dot(c2.rgb, Lw), dot(c3.rgb, Lw));

	float g_fallOffContrast = 0.6; // Hardcoded from Mikkelsen's defaults
	float g_exp = 7.0;             // Hardcoded from Mikkelsen's defaults

	Dw = mix(vec3(1.0), Dw, g_fallOffContrast);
	vec3 W = Dw * pow(vec3(w1, w2, w3), vec3(g_exp));
	W /= (W.x + W.y + W.z);

	// Apply contrast curve
	if(r != 0.5) {
		W = Gain3(W, r);
	}

	// Blend the 3 samples together using calculated weights
	return W.x * c1 + W.y * c2 + W.z * c3;
}





vec2 hash2D2D (vec2 s)
{
	//magic numbers
	vec2 i = vec2(0.0);
	return fract(sin(modf(vec2(dot(s, vec2(127.1,311.7)), dot(s, vec2(269.5,183.3))) / 3.14159, i))*43758.5453);
}

//stochastic sampling
vec4 tex2DStochastic(sampler2D tex, vec2 uv, vec2 dx, vec2 dy)
{
	//triangle vertices and blend weights
	//BW_vx[0...2].xyz = triangle verts
	//BW_vx[3].xy = blend weights (z is unused)
	mat4 BW_vx;

	//uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
	vec2 skewUV = mat2(vec2(1.0 , 0.0) , vec2(-0.57735027, 1.15470054 )) * (uv * 3.464);

	//vertex IDs and barycentric coords
	vec2 vxID = vec2 (floor(skewUV));
	vec3 barry = vec3 (fract(skewUV), 0);
	barry.z = 1.0-barry.x-barry.y;

	BW_vx = ((barry.z > 0.0) ?
		mat4(vec4(vxID, 0, 0), vec4(vxID + vec2(0, 1), 0, 0), vec4(vxID + vec2(1, 0), 0, 0), vec4(barry, 0)) :
		mat4(vec4(vxID + vec2 (1, 1), 0, 0), vec4(vxID + vec2 (1, 0), 0, 0), vec4(vxID + vec2 (0, 1), 0, 0), vec4(-barry.z, 1.0-barry.y, 1.0-barry.x, 0.0)));

	//blend samples with calculated weights
    return textureGrad(tex, uv + hash2D2D(BW_vx[0].xy), dx, dy) * BW_vx[3].x +
        textureGrad(tex, uv + hash2D2D(BW_vx[1].xy), dx, dy) * BW_vx[3].y +
        textureGrad(tex, uv + hash2D2D(BW_vx[2].xy), dx, dy) * BW_vx[3].z;
}
vec4 hash4( vec2 p ) { return fract(sin(vec4( 1.0+dot(p,vec2(37.0,17.0)),
                                              2.0+dot(p,vec2(11.0,47.0)),
                                              3.0+dot(p,vec2(41.0,29.0)),
                                              4.0+dot(p,vec2(23.0,31.0))))*103.0); }
vec2 scale(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));

	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}
vec4 textureNoTile(sampler2D samp, in vec2 uv, float cub_a, float cub_b){
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );



	    vec4 ofa = hash4( iuv + vec2(0.0,0.0) );
	    vec4 ofb = hash4( iuv + vec2(1.0,0.0) );
	    vec4 ofc = hash4( iuv + vec2(0.0,1.0) );
	    vec4 ofd = hash4( iuv + vec2(1.0,1.0) );

	    vec2 ddx = dFdx( uv );
	    vec2 ddy = dFdy( uv );

	    // transform per-tile uvs
	    ofa.zw = sign(ofa.zw-0.5);
	    ofb.zw = sign(ofb.zw-0.5);
	    ofc.zw = sign(ofc.zw-0.5);
	    ofd.zw = sign(ofd.zw-0.5);

	    // uv's, and derivarives (for correct mipmapping)
	    vec2 uva = uv*ofa.zw + ofa.xy; vec2 ddxa = ddx*ofa.zw; vec2 ddya = ddy*ofa.zw;
	    vec2 uvb = uv*ofb.zw + ofb.xy; vec2 ddxb = ddx*ofb.zw; vec2 ddyb = ddy*ofb.zw;
	    vec2 uvc = uv*ofc.zw + ofc.xy; vec2 ddxc = ddx*ofc.zw; vec2 ddyc = ddy*ofc.zw;
	    vec2 uvd = uv*ofd.zw + ofd.xy; vec2 ddxd = ddx*ofd.zw; vec2 ddyd = ddy*ofd.zw;

	    // fetch and blend
	    vec2 b = smoothstep((cub_a/100.0),(cub_b/100.0),fuv);

	    return mix( mix( textureGrad( samp, uva, ddxa, ddya ),
	                     textureGrad( samp, uvb, ddxb, ddyb ), b.x ),
	                mix( textureGrad( samp, uvc, ddxc, ddyc ),
	                     textureGrad( samp, uvd, ddxd, ddyd ), b.x), b.y);
}

void fragment() {
	vec2 base_uv = scale(UV, uv_scale_x, uv_scale_y);
	vec2 _base_uv= scale(UV, uv_scale_x, uv_scale_y);
	
	_base_uv += vec2(offset_amount, -offset_amount); 
	
	vec4 albedo_tex = hex2colTex(texture_albedo, base_uv, rot_strength, contrast_adjust);
	albedo_tex = albedo_tex.rgba*albedo.rgba;

	vec4 final_albedo = albedo_tex;

	vec2 base_uv_b = scale(UV, uv_scale_x_b, uv_scale_y_b);
	
	vec4 albedo_tex_b = hex2colTex(texture_albedo_b, base_uv_b,rot_strength, contrast_adjust);
	albedo_tex_b = albedo_tex_b.rgba*albedo_b.rgba;

	vec4 final_albedo_b = albedo_tex_b;
	vec4 alpha_tex = texture(texture_alpha, UV);
	vec4 mix_albedo = mix(final_albedo_b, final_albedo, alpha_tex.r) ;

	
	ALBEDO = mix_albedo.rgb;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.08;

}