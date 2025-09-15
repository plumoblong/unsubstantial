extends Component
class_name ItemManager

@export var starting_items : Array[Item]

var active_item : Item = null
@export var collected : Array[Array] = []

func _ready() -> void:
	for i in range(0, starting_items.size()):
		append(starting_items[i])

func append(x : Item) -> void:
	if x.item_script != null:
		var scr : RefCounted = load(x.item_script.resource_path).new()
		if scr.has_method("pickup"):
			scr.pickup()
		else:
			print(x.id, " ", x.item_name, " no pickup()")
	collected.append([x, load(x.item_script.resource_path).new()])
	_G.game.chat.add_message("You got " + x.item_name + "!")
	match x.type:
		Item.TYPE.COMMON:
			_G.current_run.items_collected.common += 1
		Item.TYPE.UNCOMMON:
			_G.current_run.items_collected.uncommon += 1
		Item.TYPE.RARE:
			_G.current_run.items_collected.rare += 1
		Item.TYPE.LEGENDARY:
			_G.current_run.items_collected.legendary += 1
		Item.TYPE.BOSS:
			_G.current_run.items_collected.mythic += 1


func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 3 == 0:
		if not collected.is_empty():
			for i in range(0, collected.size()):
				if collected[i][1] != null:
					if collected[i][1].has_method("update"):
						collected[i][1].update(delta * 3.0)
