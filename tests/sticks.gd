extends Node
func frames(n):
 for i in n: await get_tree().physics_frame
func touch(hud,id,point,pressed):
 var e=InputEventScreenTouch.new()
 e.index=id
 e.position=point
 e.pressed=pressed
 hud._input(e)
func _ready():
 var level=preload("res://scenes/levels/Containment.tscn").instantiate()
 add_child(level)
 await frames(4)
 var h=Game.hud
 var p=Game.player
 var c=h.move_pad.global_position+h.move_pad.size*0.5
 for v in [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0)]:
  c=h.move_pad.global_position+h.move_pad.size*0.5
  var start=p.position
  var direction=p.global_basis*Vector3(v.x,0,v.y)
  touch(h,0,c+v*52,true)
  await frames(36)
  touch(h,0,c+v*52,false)
  print(v, " displacement ",p.position-start," dot ",(p.position-start).dot(direction))
  assert((p.position-start).dot(direction)>0.2,"Movement direction")
  assert(p.touch_move==Vector2.ZERO)
 var l=h.look_pad.global_position+h.look_pad.size*0.5
 var start_yaw=p.rotation.y
 touch(h,1,l+Vector2(52,0),true)
 var total=0.0
 var last=p.rotation.y
 for i in 200:
  await frames(1)
  total+=abs(angle_difference(last,p.rotation.y))
  last=p.rotation.y
 assert(total>TAU,"Full turn while held")
 touch(h,0,c+Vector2(0,-52),true)
 assert(p.touch_move.y<0 and p.touch_look.x>0,"Simultaneous sticks")
 touch(h,1,Vector2.ZERO,false)
 assert(p.touch_look==Vector2.ZERO and p.touch_move.y<0,"Independent release")
 h.toggle_pause()
 assert(p.touch_move==Vector2.ZERO and p.touch_look==Vector2.ZERO)
 print("PASS: forward, backward, left/right strafe, full held turn, simultaneous input, independent release and pause reset")
 get_tree().quit()
