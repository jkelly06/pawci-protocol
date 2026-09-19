extends Control
var turning := false
func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(_dt): queue_redraw()
func _draw():
 var c=Vector2(66,66)
 var color=Color(0.45,0.9,1.0,0.85) if turning else Color(0.55,1.0,0.75,0.85)
 draw_circle(c,64,Color(0.02,0.08,0.12,0.72))
 draw_arc(c,62,0,TAU,48,color,2)
 draw_line(c-Vector2(45,0),c+Vector2(45,0),Color(1,1,1,0.2),1)
 draw_line(c-Vector2(0,45),c+Vector2(0,45),Color(1,1,1,0.2),1)
 var value=Vector2.ZERO
 if is_instance_valid(Game.player): value=Game.player.touch_look if turning else Game.player.touch_move
 draw_circle(c+value*40,21,color)
 draw_string(ThemeDB.fallback_font,Vector2(19,-8),"TURN / AIM" if turning else "MOVE",HORIZONTAL_ALIGNMENT_LEFT,-1,15,color)
 draw_string(ThemeDB.fallback_font,Vector2(12,150),"HOLD TO TURN" if turning else "FWD / BACK / SIDE",HORIZONTAL_ALIGNMENT_LEFT,-1,11,color)
