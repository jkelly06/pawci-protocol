extends SceneTree
func _initialize():
 change_scene_to_file("res://scenes/levels/Containment.tscn")
 await process_frame
 await process_frame
 await create_timer(1.0).timeout
 var game=root.get_node("Game")
 assert(paused)
 assert(is_instance_valid(game.hud.front_end))
 assert(game.hud.front_end.get_child(2).get_rect().end.y<=540)
 game.hud.start_play()
 assert(not paused)
 game.difficulty=0
 game.hurt(10)
 assert(game.health==94)
 game.difficulty=2
 game.hurt(10)
 assert(game.health==80)
 game.difficulty=1
 await create_timer(0.5).timeout

 game.hud.toggle_pause()
 assert(paused)
 game.hud.toggle_pause()
 assert(not paused)
 print("PASS title, start, difficulty and pause")
 quit()
