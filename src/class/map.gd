extends NavigationRegion3D
class_name Map

@onready var map_builder : FuncGodotMap = get_node("Builder")

var map_name : String = "unnamed"
var chapter_id : int = 1
var map_building : bool = false

signal level_built
signal level_failed

func _ready() -> void:
	_G.game.current_map = self
	map_builder.build_complete.connect(map_build_complete)
	map_builder.build_failed.connect(map_build_failed)
	level_built.connect(_G.game.map_build_complete)
	level_failed.connect(_G.game.map_build_failed)
	
func build(file_path : String) -> void:
	map_building = true
	map_builder.map_settings = _G.MAP_SETTINGS
	map_builder.local_map_file = file_path
	_G.game.current_map_path = file_path
	map_builder.build()
	
	
func map_build_complete() -> void:
	
	bake_navigation_mesh(true)
	
func map_build_failed() -> void:
	_T.say("Map failed to build. Check the log for more information", Color.RED)
	level_failed.emit()
	map_building = false

func set_data(data : Dictionary) -> void:
	map_name = data["map_name"]
	chapter_id = data["chapter_id"]
	
func bake_finished() -> void:
	_G.game.set_env(chapter_id)
	level_built.emit()
	map_building = false
	_G.game.update_rpc()
