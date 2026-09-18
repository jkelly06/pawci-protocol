extends SceneTree
func _initialize():
 change_scene_to_file("res://scenes/levels/Containment.tscn")
 await process_frame
 await create_timer(1.5).timeout
 var game=root.get_node("Game")
 var level=game.level
 game.player.position=level.location(4,12)
 game.player.rotation.y=-PI/2
 game.player.camera.rotation.x=-0.06
 game.hud.message("RESEARCH EAST // LOCATE RED CLEARANCE")
 for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
 await create_timer(0.5).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://PREVIEW.png")
 quit()
