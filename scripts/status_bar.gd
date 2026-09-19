extends Control
func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 offset_top=-74
func _process(_dt): queue_redraw()
func _draw():
 var font=ThemeDB.fallback_font
 var cream=Color("edf3dd")
 var amber=Color("ffbd69")
 draw_rect(Rect2(Vector2.ZERO,size),Color("081b20"))
 draw_line(Vector2.ZERO,Vector2(size.x,0),Color("668e89"),2)
 var names=["VITALS","TUNA BLASTER","SECURITY","HOSTILES"]
 var values=["%03d%%" % Game.health,"%02d / %03d" % [Game.magazine,Game.reserve],"RED KEY" if Game.red_key else "NO KEY","%02d" % get_tree().get_nodes_in_group("enemies").size()]
 var width=size.x/4.0
 for i in 4:
  var x=18+i*width
  draw_string(font,Vector2(x,21),names[i],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("96b1ab"))
  draw_string(font,Vector2(x,51),values[i],HORIZONTAL_ALIGNMENT_LEFT,-1,23,amber if i==0 else cream)
  if i>0: draw_line(Vector2(x-12,12),Vector2(x-12,58),Color("294a4c"))
 draw_rect(Rect2(18,60,(width-36)*Game.health/100.0,4),amber)
