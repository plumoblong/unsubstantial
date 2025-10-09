extends NavigationRegion3D
class_name Map

@export var use_auto_build : bool = false

var map_name : String = "unnamed"
var chapter_id : int = 1
var bake_navmesh : bool = true

var map_building : bool = false

@export var map_builder : FuncGodotMap 

signal level_built
signal level_failed

func _ready() -> void:
	if not use_auto_build: return
	map_builder.build_complete.connect(map_build_complete)
	map_builder.build_failed.connect(map_build_failed)
	level_built.connect(_G.game.map_build_complete)
	level_failed.connect(_G.game.map_build_failed)
	
func build(file_path : String) -> void:
	map_builder.local_map_file = file_path
	map_builder.build()
	map_building = true
	
func map_build_complete() -> void:
	if bake_navmesh:
		bake_navigation_mesh()
	else: bake_finished()
	

func map_build_failed() -> void:
	_T.say("Map failed to build. Check the log for more information", Color.RED)
	level_failed.emit()
	map_building = false
	
func bake_finished() -> void:
	level_built.emit()
	map_building = false
