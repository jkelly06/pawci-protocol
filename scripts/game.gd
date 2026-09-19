extends Node
signal changed
var difficulty := 1
var level_number := 1
var restarting := false
var skip_start_screen := false
var player
var level
var hud
var health := 100
var magazine := 12
var reserve := 48
var red_key := false
var kills := 0
var secret := false
var finished := false
var elapsed := 0.0
func _ready():
 var keys = {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"sprint":KEY_SHIFT,"jump":KEY_SPACE,"reload":KEY_R,"interact":KEY_E,"pause":KEY_ESCAPE}
 for action in keys:
  InputMap.add_action(action)
  var event = InputEventKey.new()
  event.physical_keycode = keys[action]
  InputMap.action_add_event(action,event)
 InputMap.add_action("fire")
 var mouse = InputEventMouseButton.new()
 mouse.button_index = MOUSE_BUTTON_LEFT
 InputMap.action_add_event("fire",mouse)
func _process(dt):
 if not finished and health > 0: elapsed += dt
func reset():
 health=100
 magazine=12
 reserve=48
 red_key=false
 kills=0
 secret=false
 finished=false
 elapsed=0
 get_tree().paused=false
func restart():
 if restarting: return
 restarting=true
 skip_start_screen=true
 # Reload after the button's input callback has finished.
 call_deferred("_restart_scene")
func _restart_scene():
 reset()
 var result=get_tree().reload_current_scene()
 restarting=false
 if result!=OK:
  skip_start_screen=false
  push_error("Unable to reload containment: %s" % result)
func message(s: String):
 if is_instance_valid(hud): hud.message(s)
func hurt(amount: int):
 if health <= 0 or finished: return
 var scale=[0.6,1.0,1.4][difficulty]
 health=maxi(0,health-maxi(1,int(round(amount*scale))))
 Sound.play("damage")
 hud.flash=0.5
 changed.emit()
 if health==0: hud.end_screen(false)
func complete():
 if finished: return
 finished=true
 Sound.play("elevator")
 hud.end_screen(true)

func next_level():
 if not finished or level_number!=1 or restarting: return
 restarting=true
 skip_start_screen=true
 call_deferred("_load_level_two")
func _load_level_two():
 reset()
 var result=get_tree().change_scene_to_file("res://scenes/levels/Reactor.tscn")
 restarting=false
 if result!=OK: push_error("Unable to load Reactor Depths")
