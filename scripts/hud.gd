extends CanvasLayer
var root: Control
var stats: Label
var objective: Label
var toast: Label
var subtitles: Label
var crosshair: Label
var shade: ColorRect
var panel: PanelContainer
var panel_title: Label
var resume_button: Button
var flash := 0.0
var hit_timer := 0.0
var toast_timer := 0.0
var subtitle_timer := 0.0
var mobile := false
var move_id := -1
var look_id := -1
var move_origin := Vector2.ZERO
func label_at(text:String,anchor:Vector2,offset:Vector2,font_size:int) -> Label:
 var label=Label.new()
 label.text=text
 label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 label.anchor_left=anchor.x
 label.anchor_right=anchor.x
 label.anchor_top=anchor.y
 label.anchor_bottom=anchor.y
 label.position=offset
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",Color("b5eee6"))
 root.add_child(label)
 return label
func _ready():
 Game.hud=self
 layer=2
 process_mode=Node.PROCESS_MODE_ALWAYS
 root=Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(root)
 var bar=ColorRect.new()
 bar.color=Color("10232e")
 bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bar.offset_top=-58
 bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root.add_child(bar)
 stats=label_at("",Vector2(0,1),Vector2(16,-52),22)
 objective=label_at("",Vector2(0,1),Vector2(16,-25),13)
 label_at("PAWCI PROTOCOL   /   01 CONTAINMENT",Vector2.ZERO,Vector2(16,12),17)
 label_at("WASD move  •  SHIFT sprint  •  SPACE jump  •  E use  •  R reload",Vector2.ZERO,Vector2(16,35),12)
 toast=label_at("",Vector2(0,0.15),Vector2(16,0),17)
 subtitles=label_at("",Vector2(0,1),Vector2(16,-103),15)
 subtitles.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 crosshair=label_at("+",Vector2(0.5,0.5),Vector2(-6,-14),24)
 shade=ColorRect.new()
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 shade.color=Color(1,0,0,0)
 root.add_child(shade)
 panel=PanelContainer.new()
 panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 panel.offset_left=-210
 panel.offset_right=210
 panel.offset_top=-130
 panel.offset_bottom=130
 root.add_child(panel)
 var column=VBoxContainer.new()
 column.add_theme_constant_override("separation",12)
 panel.add_child(column)
 panel_title=Label.new()
 panel_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 panel_title.add_theme_font_size_override("font_size",21)
 column.add_child(panel_title)
 resume_button=Button.new()
 resume_button.text="RESUME"
 resume_button.pressed.connect(toggle_pause)
 column.add_child(resume_button)
 var restart=Button.new()
 restart.text="RESTART CONTAINMENT"
 restart.pressed.connect(func(): Game.restart())
 column.add_child(restart)
 var quit=Button.new()
 quit.text="QUIT"
 quit.pressed.connect(func(): get_tree().quit())
 column.add_child(quit)
 panel.hide()
 mobile=OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args()
 if mobile: build_touch()
 Game.changed.connect(refresh)
 refresh()
func refresh():
 stats.add_theme_font_size_override("font_size", 16 if root.size.x<650 else 22)
 stats.text="HP %03d     AMMO %02d / %03d     KEY %s" % [Game.health,Game.magazine,Game.reserve,"RED" if Game.red_key else "—"]
 objective.text="LEVEL 1   |   HOSTILES %d   |   %s" % [get_tree().get_nodes_in_group("enemies").size(),"REACH THE ELEVATOR" if Game.red_key else "FIND RED SECURITY KEY"]
func _process(dt):
 flash=maxf(0,flash-dt)
 hit_timer=maxf(0,hit_timer-dt)
 shade.color=Color(0.9,0.08,0.1,flash*0.65)
 crosshair.text="×" if hit_timer>0 else "+"
 if not get_tree().paused:
  toast_timer-=dt
  subtitle_timer-=dt
 toast.visible=toast_timer>0
 subtitles.visible=subtitle_timer>0
 subtitles.size.x=root.size.x-32
 refresh()
func message(text:String):
 toast.text=text
 toast_timer=4
func subtitle(text:String):
 subtitles.text=text
 subtitle_timer=8
func _unhandled_input(event):
 if event.is_action_pressed("pause") and Game.health>0 and not Game.finished: toggle_pause()
 if not mobile or get_tree().paused: return
 if event is InputEventScreenTouch:
  if event.pressed:
   if event.position.x<get_viewport().get_visible_rect().size.x*0.4 and move_id==-1:
    move_id=event.index
    move_origin=event.position
   elif look_id==-1: look_id=event.index
  else:
   if event.index==move_id:
    move_id=-1
    Game.player.touch_move=Vector2.ZERO
   if event.index==look_id: look_id=-1
 elif event is InputEventScreenDrag:
  if event.index==move_id: Game.player.touch_move=((event.position-move_origin)/65).limit_length()
  elif event.index==look_id: Game.player.look(event.relative*1.8)
func toggle_pause():
 get_tree().paused=not get_tree().paused
 panel.visible=get_tree().paused
 panel_title.text="PAWCI PROTOCOL\nPAUSED"
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_CAPTURED
 Game.player.touch_fire=false
 Game.player.touch_move=Vector2.ZERO
func end_screen(won:bool):
 get_tree().paused=true
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 panel.show()
 resume_button.hide()
 panel_title.text=("CONTAINMENT WING CLEARED\nLEVEL COMPLETE" if won else "NINE LIVES. ZERO REMAINING.\nRESEARCH SUBJECT LOST")+"\n%d kills • %02d:%02d • Secret %s" % [Game.kills,int(Game.elapsed)/60,int(Game.elapsed)%60,"YES" if Game.secret else "NO"]
func build_touch():
 label_at("DRAG TO MOVE",Vector2(0,1),Vector2(22,-145),14)
 var actions=["FIRE","USE","RELOAD","PAUSE"]
 for i in actions.size():
  var button=Button.new()
  button.text=actions[i]
  button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
  button.position=Vector2(-100,-125-i*55)
  button.size=Vector2(90,48)
  root.add_child(button)
  if i==0:
   button.button_down.connect(func(): Game.player.touch_fire=true)
   button.button_up.connect(func(): Game.player.touch_fire=false)
  elif i==1: button.pressed.connect(func(): Game.player.interact())
  elif i==2: button.pressed.connect(func(): Game.player.weapon.reload())
  else: button.pressed.connect(toggle_pause)
