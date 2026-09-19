extends CharacterBody3D
signal died(enemy)
@export var mouse := false
@export var final_guard := false
var hp := 50
var state := "IDLE"
var cooldown := 0.0
var stun := 0.0
var route_time := 0.0
var route := PackedVector3Array()
var visual: Node3D
var rat_sprite: Sprite3D
var scurry_time := 0.0
var home := Vector3.ZERO
var patrol_phase := 0.0
func _ready():
 add_to_group("enemies")
 hp=20 if mouse else 50
 collision_layer=4
 collision_mask=1|2
 home=position
 var shape=BoxShape3D.new()
 shape.size=Vector3(0.55,0.65,0.65) if mouse else Vector3(0.95,0.9,0.95)
 var col=CollisionShape3D.new()
 col.shape=shape
 col.position.y=shape.size.y/2
 add_child(col)
 visual=Node3D.new()
 add_child(visual)
 if mouse:
  rat_sprite=Sprite3D.new()
  rat_sprite.texture=preload("res://assets/art/rat.png")
  rat_sprite.pixel_size=1.15/rat_sprite.texture.get_height()
  rat_sprite.position.y=0.50
  rat_sprite.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y
  rat_sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR
  rat_sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
  rat_sprite.alpha_scissor_threshold=0.15
  rat_sprite.shaded=true
  rat_sprite.double_sided=true
  visual.add_child(rat_sprite)
  return
 var rover=Sprite3D.new()
 rover.texture=preload("res://assets/art/security-rover.png")
 rover.pixel_size=1.4/rover.texture.get_width()
 rover.position.y=0.38
 rover.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y
 rover.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR
 rover.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 rover.alpha_scissor_threshold=0.15
 rover.shaded=true
 rover.double_sided=true
 visual.add_child(rover)
func can_see_player() -> bool:
 var from=global_position+Vector3.UP*0.55
 var target=Game.player.global_position+Vector3.UP*0.7
 var hit=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,target,3))
 return not hit.is_empty() and hit.collider==Game.player
func _physics_process(dt):
 if hp<=0 or Game.health<=0 or Game.finished: return
 cooldown=maxf(0,cooldown-dt)
 stun=maxf(0,stun-dt)
 var distance=global_position.distance_to(Game.player.global_position)
 if state in ["IDLE","PATROL"]:
  patrol_phase+=dt
  state="PATROL"
  if distance<15 and can_see_player():
   state="DETECT PLAYER"
   Sound.play("detect")
  else:
   var offset=home+Vector3(sin(patrol_phase*0.7)*0.6,0,0)-global_position
   velocity.x=offset.x
   velocity.z=offset.z
 if state not in ["IDLE","PATROL"]:
  state="TAKE DAMAGE" if stun>0 else "CHASE"
  route_time-=dt
  if route_time<=0:
   route=Game.level.path_between(global_position,Game.player.global_position)
   route_time=0.4
  var target=Game.player.global_position
  if not can_see_player() and route.size()>1: target=route[1]
  var dir=target-global_position
  dir.y=0
  dir=dir.normalized()
  var speed=4.0 if mouse else 2.4
  velocity.x=dir.x*speed if stun<=0 else 0.0
  velocity.z=dir.z*speed if stun<=0 else 0.0
  if dir.length()>0.1: visual.rotation.y=atan2(-dir.x,-dir.z)
  if distance<(1.55 if mouse else 1.3) and cooldown<=0 and can_see_player():
   state="ATTACK"
   cooldown=1.2
   if mouse and is_on_floor(): velocity.y=4
   Game.hurt(5 if mouse else 10)
   Sound.play("attack")
 if not is_on_floor(): velocity.y-=20*dt
 move_and_slide()
 if mouse and is_instance_valid(rat_sprite):
  var moving=Vector2(velocity.x,velocity.z).length()>0.2
  scurry_time+=dt*(18.0 if moving else 3.0)
  rat_sprite.position.y=0.50+abs(sin(scurry_time))*(0.025 if moving else 0.003)
func take_damage(amount: int):
 if hp<=0: return
 hp-=amount
 stun=0.16
 state="TAKE DAMAGE"
 visual.scale=Vector3(1.15,0.8,1.15)
 create_tween().tween_property(visual,"scale",Vector3.ONE,0.17)
 if hp<=0:
  state="DIE"
  collision_layer=0
  remove_from_group("enemies")
  Game.kills+=1
  died.emit(self)
  Game.changed.emit()
  queue_free()
