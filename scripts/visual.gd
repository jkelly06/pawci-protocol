extends RefCounted
class_name LabVisual
static func material(color: Color, glow: float = 0.0) -> StandardMaterial3D:
 var m=StandardMaterial3D.new()
 m.albedo_color=color
 m.roughness=0.85
 if glow>0:
  m.emission_enabled=true
  m.emission=color
  m.emission_energy_multiplier=glow
 return m
static func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, solid: bool=false) -> MeshInstance3D:
 var mesh=MeshInstance3D.new()
 var cube=BoxMesh.new()
 cube.size=size
 mesh.mesh=cube
 mesh.material_override=mat
 mesh.position=pos
 parent.add_child(mesh)
 if solid:
  var body=StaticBody3D.new()
  var col=CollisionShape3D.new()
  var shape=BoxShape3D.new()
  shape.size=size
  col.shape=shape
  body.add_child(col)
  mesh.add_child(body)
 return mesh
static func sign_text(parent: Node3D, text: String, pos: Vector3, size: int=32):
 var label=Label3D.new()
 label.text=text
 label.position=pos
 label.font_size=size
 label.pixel_size=0.009
 label.modulate=Color("85eee1")
 label.no_depth_test=false
 parent.add_child(label)
 return label
static func wall_material() -> StandardMaterial3D:
 var im=Image.create(32,32,false,Image.FORMAT_RGB8)
 for y in 32:
  for x in 32:
   var c=Color("344b56")
   if y%16==0 or x==0: c=Color("14272f")
   elif y>25: c=Color("25373d")
   elif (x*7+y*3)%17==0: c=Color("425965")
   im.set_pixel(x,y,c)
 var m=material(Color.WHITE)
 m.albedo_texture=ImageTexture.create_from_image(im)
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
 return m
