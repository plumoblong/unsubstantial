extends Node

func _ready() -> void:
	get_parent().connect("dungeon_done_generating", remove_doors)

func remove_doors() -> void:
	for i : RefCounted in get_parent().get_doors():
		if i.get_room_leads_to() == null:
			i.door_node.queue_free()
