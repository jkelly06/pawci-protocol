extends Node3D
const CELL=3.0
var key_cell=Vector2(26,10)
var exit_cell=Vector2(15,37)
var cells={}
var blocked={}
var nav=AStarGrid2D.new()
var arena_started := false
var arena_clear := false
var arena_left := 0
var lift
var arena_light: OmniLight3D
var pa_timer := 8.0
var pa_index := 0
var lamps: Array[OmniLight3D]=[]
var time := 0.0
func carve(x0:int,z0:int,x1:int,z1:int):
 for z in range(z0,z1+1):
  for x in range(x0,x1+1): cells[Vector2i(x,z)]=true
func location(x:int,z:int) -> Vector3:
 return Vector3(x*CELL,0,z*CELL)
func _ready():
 Game.level=self
 Game.level_number=2
 carve(12,2,18,6)
 carve(15,7,15,11)
 carve(10,12,20,17)
 carve(21,14,25,14)
 carve(24,8,28,13)
 carve(5,14,9,14)
 carve(2,11,5,18)
 carve(15,18,15,24)
 carve(8,25,22,32)
 carve(15,33,15,35)
 carve(12,36,18,38)
 carve(3,19,3,21)
 carve(2,22,6,24)
 var wall=LabVisual.wall_material()
 var floor_mat=LabVisual.material(Color("25362c"))
 var ceiling_mat=LabVisual.material(Color("111e2a"))
 for c in cells:
  var pos=location(c.x,c.y)
  LabVisual.box(self,pos+Vector3(0,-0.15,0),Vector3(3,0.3,3),floor_mat,true)
  LabVisual.box(self,pos+Vector3(0,3.15,0),Vector3(3,0.3,3),ceiling_mat)
  for dir in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
   if not cells.has(c+dir):
    var size=Vector3(0.2,3,3) if dir.x!=0 else Vector3(3,3,0.2)
    LabVisual.box(self,pos+Vector3(dir.x*1.5,1.5,dir.y*1.5),size,wall,true)
  if c.x%4==0 and c.y%4==0:
   var lamp=OmniLight3D.new()
   lamp.position=pos+Vector3(0,2.65,0)
   lamp.omni_range=10
   lamp.light_color=Color("8cffa5") if c.y<24 else Color("ff9c35")
   lamp.light_energy=1.1
   add_child(lamp)
   lamps.append(lamp)
   LabVisual.box(self,pos+Vector3(0,2.96,0),Vector3(1.2,0.05,0.3),LabVisual.material(lamp.light_color,1))
 var environment=WorldEnvironment.new()
 var env=Environment.new()
 env.background_mode=Environment.BG_COLOR
 env.background_color=Color("09111d")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color("92b5c7")
 env.ambient_light_energy=0.43
 environment.environment=env
 add_child(environment)
 nav.region=Rect2i(0,0,31,40)
 nav.cell_size=Vector2(CELL,CELL)
 nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
 nav.update()
 for z in 40:
  for x in 31: nav.set_point_solid(Vector2i(x,z),not cells.has(Vector2i(x,z)))
 spawn_door(15,9,false,false,false)
 spawn_door(15,22,true,false,false)
 spawn_door(3,20,false,true,false)
 lift=spawn_door(15,35,false,false,true)
 var player=preload("res://scenes/player/Player.tscn").instantiate()
 player.position=location(15,3)+Vector3(0,0.1,0)
 player.rotation.y=PI
 add_child(player)
 var retro=CanvasLayer.new()
 retro.layer=1
 add_child(retro)
 var filter=ColorRect.new()
 filter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 filter.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var shader=ShaderMaterial.new()
 shader.shader=preload("res://scripts/retro.gdshader")
 filter.material=shader
 retro.add_child(filter)
 var hud=preload("res://scenes/ui/HUD.tscn").instantiate()
 add_child(hud)
 for entry in [[14,5,"ammo"],[16,5,"health"],[11,13,"ammo"],[19,16,"health"],[25,12,"ammo"],[26,10,"key"],[3,16,"health"],[4,23,"ammo"],[5,23,"health"],[15,24,"ammo"],[9,26,"ammo"],[21,26,"health"],[9,31,"health"],[21,31,"ammo"],[14,34,"ammo"]]:
  spawn_pickup(entry[0],entry[1],entry[2])
 for entry in [[12,14,false],[18,15,false],[17,16,true],[25,14,true],[25,11,false],[27,9,false],[27,12,true],[4,12,true],[3,17,false],[15,19,false],[15,24,true]]:
  spawn_enemy(entry[0],entry[1],entry[2],false)
 signage("02 // REACTOR DEPTHS\nRESTORE CLEARANCE. REACH THE SURFACE.",15,6)
 signage("REACTOR SOUTH / KEY EAST\nSUPPLIES WEST",15,17)
 signage("REACTOR ACCESS CARD",26,12)
 signage("EMERGENCY SUPPLY CACHE",4,24)
 signage("CORE GUARDIAN // STAND CLEAR",15,32)
 signage("SURFACE LIFT // FREEDOM",15,38)
 for coord in [Vector2i(12,3),Vector2i(18,3),Vector2i(10,12),Vector2i(20,12),Vector2i(24,8),Vector2i(28,8),Vector2i(8,28),Vector2i(22,28)]:
  prop(location(coord.x,coord.y))
 Game.message("REACTOR DEPTHS // FIND THE RED ACCESS CARD")
func signage(text:String,x:int,z:int):
 var sign=LabVisual.sign_text(self,text,location(x,z)+Vector3(0,2.1,1.32),26)
 sign.rotation.y=PI
func prop(pos:Vector3):
 var dark=LabVisual.material(Color("203b48"))
 LabVisual.box(self,pos+Vector3(0,0.45,0),Vector3(0.9,0.9,0.65),dark,true)
 LabVisual.box(self,pos+Vector3(0,0.98,0),Vector3(0.8,0.12,0.6),LabVisual.material(Color("62d6c7"),0.8))
 LabVisual.box(self,pos+Vector3(0.55,1.45,0.4),Vector3(0.12,2.9,0.12),LabVisual.material(Color("a08b64")))
func spawn_pickup(x:int,z:int,kind:String):
 var names={"ammo":"AmmoPickup","health":"HealthPickup","key":"RedKey"}
 var item=load("res://scenes/pickups/"+names[kind]+".tscn").instantiate()
 item.position=location(x,z)
 add_child(item)
 return item
func spawn_enemy(x:int,z:int,mouse:bool,guard:bool):
 var filename="TinCanMouse" if mouse else "VacuumDrone"
 var enemy=load("res://scenes/enemies/"+filename+".tscn").instantiate()
 enemy.position=location(x,z)+Vector3(0,0.05,0)
 enemy.final_guard=guard
 enemy.died.connect(on_enemy_died)
 add_child(enemy)
 if guard: arena_left+=1
 return enemy
func spawn_door(x:int,z:int,locked:bool,secret:bool,exit_gate:bool):
 var door=preload("res://scenes/doors/Door.tscn").instantiate()
 door.position=location(x,z)
 door.locked=locked
 door.secret=secret
 door.exit_gate=exit_gate
 add_child(door)
 blocked[Vector2i(x,z)]=true
 nav.set_point_solid(Vector2i(x,z),true)
 return door
func unblock(pos:Vector3):
 var cell=Vector2i(roundi(pos.x/CELL),roundi(pos.z/CELL))
 blocked.erase(cell)
 nav.set_point_solid(cell,false)
func path_between(from:Vector3,to:Vector3) -> PackedVector3Array:
 var a=Vector2i(roundi(from.x/CELL),roundi(from.z/CELL))
 var b=Vector2i(roundi(to.x/CELL),roundi(to.z/CELL))
 var result=PackedVector3Array()
 if not nav.is_in_boundsv(a) or not nav.is_in_boundsv(b) or nav.is_point_solid(a) or nav.is_point_solid(b): return result
 for point in nav.get_id_path(a,b): result.append(location(point.x,point.y))
 return result
func begin_arena():
 if arena_started: return
 arena_started=true
 Game.message("REACTOR LOCKDOWN // DEFEAT THE CORE GUARDIAN")
 Sound.play("alarm")
 for entry in [[10,28,false],[20,28,false],[12,30,true],[18,30,true],[15,31,false],[11,27,true],[19,27,true]]:
  var enemy=spawn_enemy(entry[0],entry[1],entry[2],true)
  enemy.state="CHASE"
  if entry[0]==15:
   enemy.hp=175
   enemy.visual.scale=Vector3(1.4,1.4,1.4)
   LabVisual.sign_text(enemy,"CORE GUARDIAN",Vector3(0,1.8,0),22)
func on_enemy_died(enemy):
 if enemy.final_guard:
  arena_left-=1
  if arena_left==0:
   arena_clear=true
   for lamp in lamps:
    if lamp.position.z>70: lamp.light_color=Color("5ce7a5")
   lift.interact()
   Game.message("REACTOR SECURED // TAKE THE SURFACE LIFT")
func _process(dt):
 time+=dt
 for i in lamps.size(): lamps[i].light_energy=1.0+sin(time*9+i*17)*0.09
 if not is_instance_valid(Game.player) or Game.health<=0 or Game.finished: return
 if Game.player.position.z>74: begin_arena()
 if arena_clear and Game.player.position.z>108: Game.complete()
 pa_timer-=dt
 if pa_timer<=0:
  var lines=["Reactor personnel: please stop feeding the cooling system.","The Core Guardian is not a vacuum cleaner. Do not pet it.","Subjects are reminded that unauthorized scratching is prohibited.","Please remain calm. The facility is completely under control."]
  Game.hud.subtitle("DR. PAWCI // "+lines[pa_index%lines.size()])
  pa_index+=1
  pa_timer=33
