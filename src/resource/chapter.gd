extends Resource
class_name Chapter

@export var chapter_name : String = "The Void"
@export var description : String = "Destiny Unclear"
@export var id : int = 0

@export var environment : Environment
@export var materials : ChapterMaterials

@export var y_boundary : float = -15.0
@export var rooms : Array[PackedScene]
@export var end_room : PackedScene
@export var chapter_end_room : PackedScene
@export var key_room : PackedScene
@export var ambience_streams : Array[AudioStream]
@export var ambience_position : Vector3 = Vector3(100.0, 10.0, 100.0)

func get_material(material : ChapterMaterials.MAT) -> Material:
	return materials.materials[material]
