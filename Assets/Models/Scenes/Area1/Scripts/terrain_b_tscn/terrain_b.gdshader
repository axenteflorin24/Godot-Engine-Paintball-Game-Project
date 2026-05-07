shader_type spatial;
render_mode cull_disabled;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;

uniform float cubic_a = 1;
uniform float cubic_b = 10;
uniform float uv_scale_x=1;
uniform float uv_scale_y=1;


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
vec4 textureNoTile(sampler2D samp, in vec2 uv){
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
	    vec2 b = smoothstep((cubic_a/100.0),(cubic_b/100.0),fuv);

	    return mix( mix( textureGrad( samp, uva, ddxa, ddya ),
	                     textureGrad( samp, uvb, ddxb, ddyb ), b.x ),
	                mix( textureGrad( samp, uvc, ddxc, ddyc ),
	                     textureGrad( samp, uvd, ddxd, ddyd ), b.x), b.y);
}

void fragment() {
	vec2 base_uv = scale(UV, uv_scale_x, uv_scale_y);
	
	vec4 albedo_tex = textureNoTile(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb*albedo.rgb;
}