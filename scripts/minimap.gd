extends Control
var joystick := false
func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(_dt):
 queue_redraw()
func _draw():
 if joystick:
  draw_circle(Vector2(60,60),58,Color(0.05,0.2,0.25,0.45))
  draw_arc(Vector2(60,60),58,0,TAU,48,Color(0.5,0.9,0.9,0.7),2)
  var movement=Game.player.touch_move if is_instance_valid(Game.player) else Vector2.ZERO
  draw_circle(Vector2(60,60)+movement*36,20,Color(0.5,0.9,0.9,0.6))
  return
 draw_rect(Rect2(Vector2.ZERO,size),Color(0.02,0.07,0.1,0.88))
 draw_rect(Rect2(Vector2.ZERO,size),Color(0.3,0.7,0.75),false,1)
 var font=ThemeDB.fallback_font
 draw_string(font,Vector2(10,17),"MAP   /   YOU",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.CYAN)
 if not is_instance_valid(Game.level): return
 var scale_factor=4.3
 var origin=Vector2(12,24)
 for cell in Game.level.cells:
  draw_rect(Rect2(origin+Vector2(cell)*scale_factor,Vector2.ONE*scale_factor),Color(0.25,0.4,0.46))
 for cell in Game.level.blocked:
  draw_rect(Rect2(origin+Vector2(cell)*scale_factor,Vector2.ONE*scale_factor),Color(1,0.55,0.25))
 if not Game.red_key:
  draw_circle(origin+(Game.level.key_cell+Vector2.ONE*0.5)*scale_factor,3,Color.RED)
 draw_rect(Rect2(origin+Game.level.exit_cell*scale_factor,Vector2(5,5)),Color.GREEN)
 if is_instance_valid(Game.player):
  var pos=origin+(Vector2(Game.player.position.x,Game.player.position.z)/3.0+Vector2.ONE*0.5)*scale_factor
  var facing=Vector2(-sin(Game.player.rotation.y),-cos(Game.player.rotation.y))
  draw_circle(pos,3,Color.CYAN)
  draw_line(pos,pos+facing*9,Color.CYAN,2)
 draw_string(font,Vector2(8,205),"RED key  /  GREEN exit",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color.WHITE)
