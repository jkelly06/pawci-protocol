extends SceneTree
func _initialize():
 change_scene_to_file("res://scenes/levels/Containment.tscn")
 await process_frame
 var test=load("res://tests/level_two_test.gd").new()
 root.add_child(test)
