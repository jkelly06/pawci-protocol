extends Control
signal started
const AMBER=Color("ffbd69")
const CREAM=Color("edf3dd")
func text_line(parent:Node,text:String,font_size:int,color:Color=CREAM) -> Label:
 var label=Label.new()
 label.text=text
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",color)
 parent.add_child(label)
 return label
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var art=TextureRect.new()
 art.texture=preload("res://assets/art/containment-cover.png")
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(art)
 var veil=ColorRect.new()
 veil.color=Color(0.01,0.04,0.05,0.22)
 veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(veil)
 var column=VBoxContainer.new()
 add_child(column)
 column.position=Vector2(38,24)
 column.size=Vector2(390,450)
 column.add_theme_constant_override("separation",6)
 text_line(column,"SUBJECT 09  /  STATUS: UNCONTAINED",13,AMBER)
 var logo=text_line(column,"PAWCI",64)
 logo.add_theme_constant_override("outline_size",3)
 text_line(column,"P R O T O C O L",29,AMBER)
 text_line(column,"SMALL PAWS. BIG PROBLEM.",15,AMBER)
 text_line(column,"The cages are open. The alarms are loud.\nFind the key. Shut down the reactor.\nMake it out with your whiskers intact.",14)
 var difficulty=OptionButton.new()
 column.add_child(difficulty)
 difficulty.custom_minimum_size.y=42
 difficulty.add_item("CURIOUS CAT  /  Easy")
 difficulty.add_item("ESCAPED SUBJECT  /  Normal")
 difficulty.add_item("NINE-LIFE LEGEND  /  Hard")
 difficulty.select(Game.difficulty)
 difficulty.item_selected.connect(func(index): Game.difficulty=index)
 var start=Button.new()
 column.add_child(start)
 start.text="BREAK CONTAINMENT   >"
 start.custom_minimum_size.y=56
 start.add_theme_font_size_override("font_size",21)
 start.add_theme_color_override("font_color",Color("081b20"))
 var bright=StyleBoxFlat.new()
 bright.bg_color=AMBER
 bright.content_margin_left=18
 bright.content_margin_right=18
 start.add_theme_stylebox_override("normal",bright)
 start.pressed.connect(func(): started.emit())
 text_line(column,"2 SECTORS  /  LIVE MAP  /  TOUCH + KEYBOARD",12)
 text_line(column,"Move with the left stick. Turn with the right.\nDesktop: WASD + mouse. Escape pauses.",13)
