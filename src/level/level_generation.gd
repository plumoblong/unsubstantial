# P. B: CHECK FOR BACK2X POST DUNGEON GENERATOR FOR MORE INFORMATION

#extends Map
#class_name Dungeon
#
#@onready var navmesh : NavigationRegion3D = $NavigationRegion3D
#
#func _enter_tree() -> void:
	#_G.game.dungeon_generator = $NavigationRegion3D/DungeonGenerator3D
#
#func _ready() -> void:
	#_G.game.chapter.current.materials.pick_materials()
	#if not _G.game.chapter.current.rooms.is_empty():
		#$NavigationRegion3D/DungeonGenerator3D.room_scenes = get_room_scenes()
	#$NavigationRegion3D/DungeonGenerator3D.dungeon_size = Vector3i(9 + (_G.game.actual_stage * 2), 1, 9 + (_G.game.actual_stage * 2))
	#$NavigationRegion3D/DungeonGenerator3D.generate()
	#
#
#func dungeon_generator_3d_done_generating() -> void:
	#await get_tree().create_timer(0.25).timeout
	#navmesh.call_deferred("bake_navigation_mesh")
	##_G.game.transition.ascend_out()
	#
#func dungeon_generator_3d_generating_failed() -> void:
	#$NavigationRegion3D/DungeonGenerator3D.generate()
	#
#func get_room_scenes() -> Array[PackedScene]:
	#var rooms : Array[PackedScene]
	#var chapter_rooms : StageRooms = _G.game.chapter.current.rooms[_G.game.stage - 1]
	#for i in chapter_rooms.files:
		#rooms.append(i)
	#rooms.append(_G.game.chapter.current.key_room)
	#rooms.append(_G.game.chapter.current.end_room)
	#push_warning(rooms)
	#return rooms
