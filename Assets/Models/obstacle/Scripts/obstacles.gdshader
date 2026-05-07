shader_type spatial;
render_mode cull_disabled; // Important: Render both sides

uniform sampler2D front_texture;
uniform sampler2D back_texture;

void fragment() {
    // FRONT_FACING is true for the front side, false for the back
    if (FRONT_FACING) {
        ALBEDO = texture(front_texture, UV).rgb;
    } else {
        ALBEDO = texture(back_texture, UV).rgb;
    }
}