extends NavigationRegion3D
class_name Map

@export var map_name : String = "unnamed"
@export var chapter_id : int = 1

@export var map_builder : FuncGodotMap 

signal level_built
signal level_failed

func _ready() -> void:
	map_builder.build_complete.connect(map_build_complete)
	map_builder.build_failed.connect(map_build_failed)
	level_built.connect(_G.game.map_build_complete)
	level_failed.connect(_G.game.map_build_failed)
	
func build(file_path : String) -> void:
	map_builder.local_map_file = file_path
	map_builder.build()
	
func map_build_complete() -> void:
	bake_navigation_mesh(false)

func map_build_failed() -> void:
	_T.say("Map failed to build. Check the log for more information", Color.RED)
	level_failed.emit()
	
func bake_finished() -> void:
	level_built.emit()
