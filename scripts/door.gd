extends Node3D
@export var locked := false
@export var secret := false
@export var exit_gate := false
var opened := false
var panel: Node3D
var collider: CollisionShape3D
func _ready():
 add_to_group("doors")
 panel=Node3D.new()
 add_child(panel)
 var mat=LabVisual.material(Color("913d49") if locked else Color("496d74"))
 if secret: mat=LabVisual.wall_material()
 LabVisual.box(panel,Vector3(0,1.5,0),Vector3(3,3,0.3),mat)
 var body=StaticBody3D.new()
 collider=CollisionShape3D.new()
 var shape=BoxShape3D.new()
 shape.size=Vector3(3,3,0.3)
 collider.shape=shape
 collider.position.y=1.5
 body.add_child(collider)
 panel.add_child(body)
 if not secret:
  LabVisual.sign_text(panel,"RED CLEARANCE" if locked else ("LIFT // SEALED" if exit_gate else "E  //  OPEN"),Vector3(0,1.65,0.18),23)
  LabVisual.box(panel,Vector3(0,0.75,0.18),Vector3(2.8,0.1,0.06),LabVisual.material(Color("ffc16b"),0.5))
func interact():
 if opened: return
 if exit_gate and not Game.level.arena_clear:
  Game.message("ELEVATOR SEALED // ELIMINATE THE FINAL GUARDS")
  return
 if locked and not Game.red_key:
  Game.message("RED SECURITY CLEARANCE REQUIRED")
  return
 opened=true
 collider.set_deferred("disabled",true)
 Game.level.unblock(global_position)
 create_tween().tween_property(panel,"position:y",3.15,0.7)
 Sound.play("door")
 if secret:
  Game.secret=true
  Game.message("SECRET FOUND // EXECUTIVE CATNAP SUITE")
  Sound.play("secret")
