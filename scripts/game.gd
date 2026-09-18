extends Node
signal changed
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
 health=maxi(0,health-amount)
 Sound.play("damage")
 hud.flash=0.5
 changed.emit()
 if health==0: hud.end_screen(false)
func complete():
 if finished: return
 finished=true
 Sound.play("elevator")
 hud.end_screen(true)
