extends Node
func wait_frames(n=5):
 for i in n: await get_tree().process_frame
func _ready():
 await wait_frames()
 Game.complete()
 assert(Game.hud.next_button.visible)
 Game.next_level()
 await wait_frames(10)
 assert(Game.level_number==2)
 assert(not get_tree().paused)
 assert(Game.health==100 and not Game.red_key)
 assert(get_tree().current_scene.name=="Reactor")
 var level=Game.level
 for door in get_tree().get_nodes_in_group("doors"):
  if not door.locked and not door.secret and not door.exit_gate: door.interact()
 await wait_frames()
 assert(level.path_between(level.location(15,3),level.location(26,10)).size()>0,"Key route reachable")
 assert(level.path_between(level.location(15,17),level.location(15,26)).is_empty(),"Red gate blocks reactor")
 Game.red_key=true
 for door in get_tree().get_nodes_in_group("doors"):
  if door.locked: door.interact()
 await wait_frames()
 assert(level.path_between(level.location(15,17),level.location(15,26)).size()>0)
 level.begin_arena()
 assert(level.arena_left==7)
 var guardian=false
 for enemy in get_tree().get_nodes_in_group("enemies"):
  if enemy.final_guard:
   if enemy.hp==175: guardian=true
   enemy.take_damage(999)
 assert(guardian)
 await wait_frames()
 assert(level.arena_clear and level.lift.opened)
 Game.player.position=level.location(15,37)
 await wait_frames()
 assert(Game.finished)
 assert(not Game.hud.next_button.visible)
 Game.restart()
 await wait_frames(10)
 assert(Game.level_number==2 and not Game.finished and not get_tree().paused)
 assert(get_tree().current_scene.name=="Reactor")
 print("PASS: Level 1 transition, Level 2 spawn/reset, key route, locked gate, guardian wave, lift exit, campaign ending and Level 2 restart")
 get_tree().quit()
