extends Resource
class_name Chapter

@export var chapter_name : String = "The Ether"
@export var description : String = "Destiny Unclear"
@export var id : int = 0

@export var environment : Environment
@export var maps : Array[String]
@export var map_fallback : String
@export var remove_maps_from_pool : bool = true

@export var y_boundary : float = -15.0
@export var ambience_streams : Array[AudioStream]
@export var ambience_position : Vector3 = Vector3(100.0, 10.0, 100.0)
