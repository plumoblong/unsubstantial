extends TextureRect

@export var label : NodePath
@export var name_label : NodePath
@export var rarity : NodePath
@export var item : Item
var hovering : bool = false

@onready var desc : RichTextLabel = get_node(label)
@onready var names : RichTextLabel = get_node(name_label)
@onready var rare : Sprite2D = get_node(rarity)

func _process(_delta : float) -> void:
	if item != null:
		texture = item.image

func mouse_entered() -> void:
	hovering = true
	modulate = Color.GRAY
	if item != null:
		desc.text = item.item_description.to_upper()
		names.text = item.item_name
		rare.frame = item.type
		rare.show()

func mouse_exited() -> void:
	hovering = false
	modulate = Color.WHITE
