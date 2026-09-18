shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 resolution = vec2(480.0, 270.0);
void fragment() {
 vec2 uv=(floor(SCREEN_UV*resolution)+0.5)/resolution;
 vec3 col=texture(screen_tex,uv).rgb;
 col=floor(col*32.0)/32.0;
 float vignette=1.0-0.28*pow(length(SCREEN_UV-0.5)*1.4,2.0);
 COLOR=vec4(col*vignette,1.0);
}
