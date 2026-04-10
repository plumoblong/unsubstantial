extends Resource
class_name Chapter

@export var chapter_name : String = "The Ether"
@export var description : String = "Destiny Unclear"
@export var id : int = 0

@export var environment : Environment
@export var maps : Array[String]
@export var boss_maps : Array[String]
@export var map_fallback : String
@export var remove_maps_from_pool : bool = true

@export var y_boundary : float = -15.0
@export var ambience_streams : Array[AudioStream]
@export var ambience_position : Vector3 = Vector3(100.0, 10.0, 100.0)

@export var color_hue_range : Vector2 = Vector2(0.0, 1.0)
@export var color_saturation_range : Vector2 = Vector2(0.5, 1.0)
@export var color_value_range : Vector2 = Vector2(0.6, 1.0)
@export var color_alpha_range : Vector2 = Vector2(1.0, 1.0)
