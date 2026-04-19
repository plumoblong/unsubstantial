extends NavigationRegion3D
class_name SpecialRoom

# a randomly chosen 384x384 units sized room

@onready var builder : FuncGodotMap = $Builder

@export var func_godot_properties : Dictionary = {
	"allow_treasure" : true,
	"allow_shop" : false,
	"allow_challenge" : false,
	"allow_shrine" : false,
}

const TREASURE_MAPS : Array[String] = [
	"res://maps/special/treasure1.map"
]

enum ROOM_TYPE {
	TREASURE,
	SHOP,
	CHALLENGE,
	SHRINE,
}

func _pick_special_room() -> ROOM_TYPE:
	var types : Array[ROOM_TYPE]
	
	if func_godot_properties["allow_treasure"]:
		types.append(ROOM_TYPE.TREASURE)
	if func_godot_properties["allow_shop"]:
		types.append(ROOM_TYPE.SHOP)
	if func_godot_properties["allow_challenge"]:
		types.append(ROOM_TYPE.CHALLENGE)
	if func_godot_properties["allow_shrine"]:
		types.append(ROOM_TYPE.SHRINE)
		
	var type : ROOM_TYPE 
	if not types.is_empty():
		type = types.pick_random()
	else:
		type = ROOM_TYPE.TREASURE
	return type 
	
func _pick_room_map() -> void:
	var picked_room : ROOM_TYPE = _pick_special_room()
	var map : String
	match picked_room:
		_:
			map = TREASURE_MAPS.pick_random()
	builder.local_map_file = map

func _func_godot_build_complete() -> void:
	_pick_room_map()
	builder.build() 
	#bake_navigation_mesh()
