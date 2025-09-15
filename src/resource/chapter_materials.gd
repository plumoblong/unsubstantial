extends Resource
class_name ChapterMaterials

enum MAT {
	FLOOR, WALL, S1, S2, S3, S4
}

@warning_ignore("shadowed_global_identifier")
@export var floor : Array[Material]
@export var wall : Array[Material]
@export var special_1 : Array[Material]
@export var special_2 : Array[Material]
@export var special_3 : Array[Material]
@export var special_4 : Array[Material]

var materials : Array[Material]

func pick_materials() -> void:
	materials = [floor.pick_random(), 
				wall.pick_random(),
				special_1.pick_random(),
				special_2.pick_random(),
				special_3.pick_random(),
				special_4.pick_random(),
	]
