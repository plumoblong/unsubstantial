extends Resource
class_name Chapter

@export var chapter_name : String = "The Ether"
@export var description : String = "Destiny Unclear"
@export var id : int = 0

## The first stage (actual_stage) at which this chapter becomes active.
## Chapters are sorted by this value — the highest stage_start that is
## still <= actual_stage wins.  Stage 0 is always the opening Ether chapter.
@export var stage_start : int = 0

@export var maps : Array[String]



@export var map_fallback : String
#@export var remove_maps_from_pool : bool = true

## if boss_stage == stage_start or boss_maps is empty, there will not be any boss in this chapter
@export var boss_stage : int = 0
@export var boss_maps : Array[String]

@export var y_boundary : float = -15.0
@export var ambience_streams : Array[AudioStream]
@export var ambience_position : Vector3 = Vector3(100.0, 10.0, 100.0)

@export var color_ranges : Gradient

#@export var color_hue_range : Vector2 = Vector2(0.0, 1.0)
#@export var color_saturation_range : Vector2 = Vector2(0.5, 1.0)
#@export var color_value_range : Vector2 = Vector2(0.6, 1.0)
#@export var color_alpha_range : Vector2 = Vector2(1.0, 1.0)
