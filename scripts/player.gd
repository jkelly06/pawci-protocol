extends CharacterBody3D
var camera: Camera3D
var weapon
var touch_look := Vector2.ZERO
var touch_move := Vector2.ZERO
var touch_fire := false
var bob := 0.0
var step_timer := 0.0
func _ready():
 Game.player=self
 collision_layer=2
 collision_mask=1
 var capsule=CapsuleShape3D.new()
 capsule.radius=0.3
 capsule.height=1.3
 var col=CollisionShape3D.new()
 col.shape=capsule
 col.position.y=0.65
 add_child(col)
 camera=Camera3D.new()
 camera.position.y=1.05
 camera.fov=82
 camera.near=0.06
 add_child(camera)
 camera.current=true
 weapon=preload("res://scenes/weapons/TunaBlaster.tscn").instantiate()
 camera.add_child(weapon)
 if not OS.has_feature("web") and not DisplayServer.is_touchscreen_available():
  Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func look(delta: Vector2):
 rotate_y(-delta.x*0.0025)
 camera.rotation.x=clampf(camera.rotation.x-delta.y*0.0025,-1.25,1.25)
func _unhandled_input(event):
 if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
  look(event.relative)
 if event.is_action_pressed("interact"): interact()
func interact():
 # Allow USE to reach a nearby pickup, but never through a wall.
 var pickup_target=null
 var pickup_distance=2.0
 for pickup in get_tree().get_nodes_in_group("pickups"):
  var d=global_position.distance_to(pickup.global_position)
  if d<pickup_distance and not pickup.collected:
   var query=PhysicsRayQueryParameters3D.create(camera.global_position,pickup.global_position+Vector3(0,0.6,0),1)
   if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
    pickup_target=pickup
    pickup_distance=d
 if pickup_target!=null:
  pickup_target.collect()
  return
 var nearest=null
 var distance=3.0
 for door in get_tree().get_nodes_in_group("doors"):
  var d=global_position.distance_to(door.global_position)
  if d<distance:
   nearest=door
   distance=d
 if nearest!=null: nearest.interact()
func _physics_process(dt):
 if Game.health<=0 or Game.finished: return
 look(touch_look*850.0*dt)
 var input=Input.get_vector("left","right","forward","back")+touch_move
 input=input.limit_length()
 var direction=global_basis*Vector3(input.x,0,input.y)
 var speed=7.0 if Input.is_action_pressed("sprint") else 4.4
 velocity.x=move_toward(velocity.x,direction.x*speed,dt*28)
 velocity.z=move_toward(velocity.z,direction.z*speed,dt*28)
 if not is_on_floor(): velocity.y-=20*dt
 elif Input.is_action_just_pressed("jump"): velocity.y=6
 move_and_slide()
 if input.length()>0.1 and is_on_floor():
  bob+=dt*12
  step_timer-=dt
  if step_timer<=0:
   Sound.play("footstep")
   step_timer=0.36
 camera.position.y=1.05+sin(bob)*0.026*input.length()
 weapon.bob=Vector2(sin(bob*0.5),abs(cos(bob)))*input.length()
 if Input.is_action_pressed("fire") or touch_fire: weapon.fire()
 if Input.is_action_just_pressed("reload"): weapon.reload()
