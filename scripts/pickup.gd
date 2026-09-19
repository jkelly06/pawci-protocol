extends Area3D
@export_enum("health","ammo","key") var kind := "health"
var visual: Node3D
var time := 0.0
var collected := false
var full_notice := false
func _ready():
 add_to_group("pickups")
 collision_layer=0
 collision_mask=2
 var col=CollisionShape3D.new()
 var sphere=SphereShape3D.new()
 sphere.radius=0.8
 col.shape=sphere
 col.position.y=0.55
 add_child(col)
 visual=Node3D.new()
 add_child(visual)
 var colors={"health":Color("62e9b0"),"ammo":Color("ffcf77"),"key":Color("ff3f5c")}
 LabVisual.box(visual,Vector3(0,0.6,0),Vector3(0.45,0.3,0.3),LabVisual.material(colors[kind],0.5))
 LabVisual.sign_text(visual,{"health":"+ CAT TREATS","ammo":"TUNA CELLS","key":"RED KEY"}[kind],Vector3(0,1.05,0),18)
func _physics_process(dt):
 time+=dt
 visual.position.y=sin(time*3)*0.10
 visual.rotation.y+=dt
 var touching=false
 for body in get_overlapping_bodies():
  if body==Game.player:
   touching=true
   collect()
 if not touching: full_notice=false
func collect():
 if collected or Game.finished or Game.health<=0: return
 if kind=="health":
  if Game.health>=100:
   if not full_notice:
    Game.message("HEALTH FULL // SAVE THESE TREATS FOR LATER")
    full_notice=true
   return
  var restored=mini(25,100-Game.health)
  Game.health+=restored
  Game.message("CAT TREATS // +%d HP" % restored)
 elif kind=="ammo": Game.reserve+=24
 else: Game.red_key=true
 collected=true
 if kind!="health":
  Game.message({"ammo":"TUNA CELLS // +24","key":"RED KEY ACQUIRED // RETURN TO SECURITY"}[kind])
 Sound.play("pickup")
 Game.changed.emit()
 queue_free()
