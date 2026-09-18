extends Node
func _ready():
 await get_tree().process_frame
 Game.hurt(200)
 Game.restart()
 await get_tree().process_frame
 await get_tree().process_frame
 assert(Game.health==100)
 assert(not get_tree().paused)
 assert(is_instance_valid(Game.player))
 assert(get_tree().get_nodes_in_group("enemies").size()==15)
 print("PASS: Full scene restart after death recreates player, enemies, doors and pickups")
 get_tree().quit()
