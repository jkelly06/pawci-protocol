extends CanvasLayer
var touch_layer: Control
var map_view: Control
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
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
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
 root.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(root)
 root.size=get_viewport().get_visible_rect().size
 get_viewport().size_changed.connect(func(): root.size=get_viewport().get_visible_rect().size)
 var bar=ColorRect.new()
 bar.color=Color("10232e")
 bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bar.offset_top=-58
 bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root.add_child(bar)
 stats=label_at("",Vector2(0,1),Vector2(16,-52),22)
 objective=label_at("",Vector2(0,1),Vector2(16,-25),13)
 label_at("PAWCI PROTOCOL   /   01 CONTAINMENT",Vector2.ZERO,Vector2(16,12),17)
 var help=label_at("WASD move  •  SHIFT sprint  •  SPACE jump  •  E use  •  R reload",Vector2.ZERO,Vector2(16,35),12)
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
 quit.visible=not OS.has_feature("web")
 quit.pressed.connect(func(): get_tree().quit())
 column.add_child(quit)
 panel.hide()
 mobile=DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args()
 map_view=preload("res://scripts/minimap.gd").new()
 root.add_child(map_view)
 map_view.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 map_view.position=Vector2(root.size.x-180,12)
 map_view.size=Vector2(164,212)
 if OS.has_feature("web"):
  mobile=mobile or bool(JavaScriptBridge.eval("navigator.maxTouchPoints > 0"))
 if mobile:
  help.text="LEFT PAD move  /  DRAG RIGHT look  /  MAP top right"
  build_touch()
 root.move_child(panel,-1)
 if OS.has_feature("web") and not Game.skip_start_screen:
  get_tree().paused=true
  Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
  panel.show()
  panel_title.text="PAWCI PROTOCOL\nTap START GAME to play"
  resume_button.text="START GAME"
 Game.skip_start_screen=false
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
 if is_instance_valid(touch_layer): touch_layer.visible=not get_tree().paused
 if is_instance_valid(map_view):
  map_view.position=Vector2(root.size.x-180,12)
  map_view.visible=not get_tree().paused
 refresh()
func message(text:String):
 toast.text=text
 toast_timer=4
func subtitle(text:String):
 subtitles.text=text
 subtitle_timer=8
func _input(event):
 # Release tracked fingers even when they end over a UI button.
 if event is InputEventScreenTouch and not event.pressed and is_instance_valid(Game.player):
  if event.index==move_id:
   move_id=-1
   Game.player.touch_move=Vector2.ZERO
  if event.index==look_id: look_id=-1
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
 resume_button.text="RESUME"
 move_id=-1
 look_id=-1
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE if get_tree().paused or mobile else Input.MOUSE_MODE_CAPTURED
 Game.player.touch_fire=false
 Game.player.touch_move=Vector2.ZERO
func end_screen(won:bool):
 get_tree().paused=true
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 panel.show()
 resume_button.hide()
 panel_title.text=("CONTAINMENT WING CLEARED\nLEVEL COMPLETE" if won else "NINE LIVES. ZERO REMAINING.\nRESEARCH SUBJECT LOST")+"\n%d kills • %02d:%02d • Secret %s" % [Game.kills,int(Game.elapsed)/60,int(Game.elapsed)%60,"YES" if Game.secret else "NO"]
func build_touch():
 touch_layer=Control.new()
 root.add_child(touch_layer)
 touch_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 touch_layer.mouse_filter=Control.MOUSE_FILTER_IGNORE
 # Controls sit inward, around the middle height, leaving the reticle clear.
 var actions=["FIRE","USE","RELOAD","JUMP","PAUSE"]
 var offsets=[Vector2(0,0),Vector2(96,0),Vector2(0,62),Vector2(96,62),Vector2(48,124)]
 for i in actions.size():
  var button=Button.new()
  touch_layer.add_child(button)
  button.text=actions[i]
  button.anchor_left=0.62
  button.anchor_top=0.45
  button.anchor_right=0.62
  button.anchor_bottom=0.45
  button.position=Vector2(root.size.x*0.62,root.size.y*0.45)+offsets[i]
  button.size=Vector2(90,54)
  button.modulate=Color(1,1,1,0.8)
  if i==0:
   button.button_down.connect(func(): Game.player.touch_fire=true)
   button.button_up.connect(func(): Game.player.touch_fire=false)
  elif i==1: button.pressed.connect(func(): Game.player.interact())
  elif i==2: button.pressed.connect(func(): Game.player.weapon.reload())
  elif i==3:
   button.pressed.connect(func():
    if Game.player.is_on_floor(): Game.player.velocity.y=6
   )
  else: button.pressed.connect(toggle_pause)
 var pad=preload("res://scripts/minimap.gd").new()
 pad.joystick=true
 touch_layer.add_child(pad)
 pad.anchor_left=0.28
 pad.anchor_right=0.28
 pad.anchor_top=0.59
 pad.anchor_bottom=0.59
 pad.position=Vector2(root.size.x*0.28-60,root.size.y*0.59-60)
 pad.size=Vector2(120,120)
