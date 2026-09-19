extends Node
func tick():
 for i in 4: await get_tree().physics_frame
func spawn_at(point:Vector3):
 var item=preload("res://scripts/pickup.gd").new()
 add_child(item)
 item.global_position=point
 return item
func _ready():
 var level=preload("res://scenes/levels/Containment.tscn").instantiate()
 add_child(level)
 await tick()
 for enemy in get_tree().get_nodes_in_group("enemies"): enemy.set_physics_process(false)
 for item in get_tree().get_nodes_in_group("pickups"): item.queue_free()
 await tick()
 Game.player.global_position=Vector3(12,0,12)
 Game.player.velocity=Vector3.ZERO
 var item=spawn_at(Vector3(12,0,12))
 Game.health=100
 await tick()
 assert(is_instance_valid(item) and not item.collected)
 assert(Game.hud.toast.text.contains("HEALTH FULL"))
 Game.health=90
 await tick()
 assert(Game.health==100)
 assert(Game.hud.toast.text.contains("+10 HP"))
 assert(not is_instance_valid(item))
 item=spawn_at(Vector3(13.7,0,12))
 Game.health=50
 await tick()
 assert(Game.health==50)
 Game.player.interact()
 assert(Game.health==75)
 item.collect()
 assert(Game.health==75)
 await tick()
 var wall=StaticBody3D.new()
 add_child(wall)
 wall.position=Vector3(12.8,1,12)
 var shape=CollisionShape3D.new()
 var box=BoxShape3D.new()
 box.size=Vector3(0.1,2,2)
 shape.shape=box
 wall.add_child(shape)
 item=spawn_at(Vector3(13.7,0,12))
 await tick()
 Game.player.interact()
 assert(Game.health==75 and not item.collected)
 print("PASS: full-health feedback, automatic pickup, actual healing, USE pickup, duplicate protection, wall blocking")
 get_tree().quit()
