extends Node
var checks := 0
func check(condition:bool,description:String):
 if not condition:
  push_error("FAIL: "+description)
  get_tree().quit(1)
 else:
  checks+=1
  print("PASS: "+description)
func tick(count:int=3):
 for i in count: await get_tree().physics_frame
func _ready():
 var level=preload("res://scenes/levels/Containment.tscn").instantiate()
 add_child(level)
 await tick(20)
 var player=Game.player
 var gun=player.weapon
 check(player.is_on_floor(),"Player rests on solid floor")
 var origin=player.position
 Input.action_press("forward")
 await tick(20)
 Input.action_release("forward")
 check(player.position.distance_to(origin)>0.3,"WASD moves player")
 var old_rotation=player.rotation.y
 player.look(Vector2(20,10))
 check(player.rotation.y!=old_rotation,"Mouse look rotates camera")
 player.position=level.location(4,4)
 player.velocity=Vector3.ZERO
 player.rotation=Vector3.ZERO
 player.camera.rotation=Vector3.ZERO
 var locked
 var normal
 var secret
 for door in get_tree().get_nodes_in_group("doors"):
  if door.locked: locked=door
  elif door.secret: secret=door
  elif not door.exit_gate: normal=door
 locked.interact()
 check(not locked.opened,"Red door refuses entry without key")
 check(level.path_between(level.location(4,19),level.location(4,23)).is_empty(),"Locked gate blocks navigation")
 normal.interact()
 await tick()
 check(normal.opened and normal.collider.disabled,"Normal sliding door opens and collision disables")
 check(not level.path_between(level.location(4,4),level.location(27,3)).is_empty(),"Red key route is reachable")
 var drone=level.spawn_enemy(4,3,false,false)
 drone.set_physics_process(false)
 await tick()
 player.camera.look_at(drone.global_position+Vector3.UP*0.45)
 gun.fire()
 check(Game.magazine==11,"Firing consumes one round")
 check(drone.hp==25,"Hitscan hits drone for 25 damage")
 gun.cooldown=0
 gun.fire()
 check(drone.hp<=0,"Second shot kills 50 HP drone")
 await tick()
 check(Game.kills==1,"Enemy death increments kill count")
 Game.magazine=3
 Game.reserve=5
 gun.reload()
 gun._process(2)
 check(Game.magazine==8 and Game.reserve==0,"Partial reload conserves total ammunition")
 Game.magazine=0
 gun.cooldown=0
 gun.fire()
 check(Game.magazine==0,"Empty weapon cannot fire or create ammo")
 Game.health=90
 var health=level.spawn_pickup(4,4,"health")
 health.collect()
 check(Game.health==100,"Health pickup clamps to 100")
 var ammo=level.spawn_pickup(4,4,"ammo")
 ammo.collect()
 check(Game.reserve==24,"Ammo pickup grants 24 reserve")
 var key=level.spawn_pickup(4,4,"key")
 key.collect()
 check(Game.red_key,"Red key pickup sets clearance")
 locked.interact()
 await tick()
 check(locked.opened and locked.collider.disabled,"Key unlocks red door")
 check(not level.path_between(level.location(4,19),level.location(4,28)).is_empty(),"Final room reachable after unlocking")
 secret.interact()
 check(Game.secret,"Secret room discovery recorded")
 var mouse=level.spawn_enemy(4,5,true,false)
 player.camera.look_at(mouse.global_position+Vector3.UP*0.3)
 mouse.state="CHASE"
 var distance=mouse.position.distance_to(player.position)
 await tick(20)
 check(mouse.position.distance_to(player.position)<distance,"Enemy chases player")
 mouse.position=player.position+Vector3(0,0,0.65)
 mouse.cooldown=0
 await tick(3)
 check(Game.health<100,"Mouse damages player")
 mouse.take_damage(25)
 check(mouse.hp<=0,"Mouse dies in one hit")
 level.lift.interact()
 check(not level.lift.opened,"Elevator remains sealed before final wave")
 level.begin_arena()
 check(level.arena_left==8,"Final encounter spawns 3 drones and 5 mice")
 for enemy in get_tree().get_nodes_in_group("enemies"):
  if enemy.final_guard: enemy.take_damage(100)
 await tick()
 check(level.arena_clear and level.lift.opened,"Eliminating final wave unlocks elevator")
 Game.hud.toggle_pause()
 check(get_tree().paused,"Pause freezes game")
 Game.hud.toggle_pause()
 check(not get_tree().paused,"Resume restores game")
 Game.hurt(200)
 check(Game.health==0 and get_tree().paused,"Death displays restart screen and pauses")
 Game.reset()
 check(Game.health==100 and Game.magazine==12 and Game.reserve==48 and not Game.red_key,"Reset restores starting state")
 player.position=level.location(9,37)
 await tick()
 check(Game.finished and get_tree().paused,"Entering cleared elevator completes level")
 print("TESTS PASSED: ",checks)
 get_tree().quit()
