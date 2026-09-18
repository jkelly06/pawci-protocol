extends Node3D
var cooldown := 0.0
var reload_time := 0.0
var recoil := 0.0
var bob := Vector2.ZERO
var flash_mesh: MeshInstance3D
func _ready():
 position=Vector3(0,-0.30,-0.56)
 var teal=LabVisual.material(Color("39aaa4"))
 var dark=LabVisual.material(Color("182c3a"))
 var orange=LabVisual.material(Color("e4ac58"))
 LabVisual.box(self,Vector3.ZERO,Vector3(0.20,0.19,0.42),teal)
 LabVisual.box(self,Vector3(0,0.08,-0.2),Vector3(0.13,0.10,0.15),dark)
 LabVisual.box(self,Vector3(0,0.11,-0.14),Vector3(0.04,0.03,0.06),orange)
 for side in [-1,1]:
  LabVisual.box(self,Vector3(side*0.16,-0.07,0.05),Vector3(0.13,0.14,0.22),orange)
  for toe in 3:
   LabVisual.box(self,Vector3(side*0.16+(toe-1)*0.037,-0.005,-0.07),Vector3(0.025,0.025,0.045),LabVisual.material(Color("fff2c5")))
 flash_mesh=LabVisual.box(self,Vector3(0,0.04,-0.34),Vector3(0.22,0.22,0.1),LabVisual.material(Color("ffe78c"),2))
 flash_mesh.visible=false
func _process(dt):
 cooldown=maxf(0,cooldown-dt)
 recoil=move_toward(recoil,0,dt*0.8)
 position=Vector3(bob.x*0.016,-0.30-bob.y*0.012,-0.56+recoil)
 rotation.z=sin(reload_time*8)*0.3 if reload_time>0 else 0.0
 flash_mesh.visible=cooldown>0.23
 if reload_time>0:
  reload_time=maxf(0,reload_time-dt)
  if reload_time==0:
   var count=mini(12-Game.magazine,Game.reserve)
   Game.magazine+=count
   Game.reserve-=count
   Game.changed.emit()
func fire():
 if cooldown>0 or reload_time>0 or Game.health<=0 or Game.finished: return
 if Game.magazine<=0:
  reload()
  return
 Game.magazine-=1
 cooldown=0.30
 recoil=0.08
 Sound.play("fire")
 Game.changed.emit()
 var camera=Game.player.camera
 var from=camera.global_position
 var query=PhysicsRayQueryParameters3D.create(from,from-camera.global_basis.z*80,5)
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty() and hit.collider.has_method("take_damage"):
  hit.collider.take_damage(25)
  Game.hud.hit_timer=0.13
 camera.rotation.x=clampf(camera.rotation.x+0.009,-1.25,1.25)
func reload():
 if reload_time>0 or Game.magazine==12 or Game.reserve<=0: return
 reload_time=1.15
 Sound.play("reload")
 Game.message("TUNA BLASTER // RECHARGING")
