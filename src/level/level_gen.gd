extends Node3D
class_name LevelGenerator

@onready var rooms : Node3D = $Rooms

@export var rooms_amount : int = 16
@export var room_scenes : Array[PackedScene]
@export var end_room : PackedScene

var direction : Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var last_dir : Vector2
var last_position : Vector3 = Vector3(0.0, 0.0, 0.0)

var registered_positions : Array[Vector3] = []
var registered_ids : Array[int] = []

func _ready() -> void:
	generate_level()

func generate_level() -> void:
	remove_all_rooms()
	for i in range(rooms_amount):
		if i != 0:
			var dir = direction[randi_range(0, 3)]
			var pos = registered_positions[i -1] + Vector3(dir.x * 30, 0.0, dir.y * 30)
			if not _G.values_match(registered_positions, pos):
				print(i, registered_positions)
				create_room(pos, i)
			else:
				registered_positions.append(Vector3.ZERO)
		else:
			create_room(Vector3.ZERO, 0)
	print("end ", registered_positions.max())

#func _physics_process(delta : float) -> void:
	#var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	#var y_dir : float = Input.get_axis("shoot", "dash")
	#$Camera3D.global_position += Vector3(Vector3(input_dir.x, y_dir, input_dir.y) * delta * 64).normalized()
	#if Input.is_action_just_pressed("jump"):
		#generate_level()
func create_room(pos : Vector3, id : float) -> void:
	var room : Node = room_scenes.pick_random().instantiate()
	rooms.add_child(room)
	room.id = id
	room.name = str(id)
	room.position = pos
	registered_positions.append(room.position)
	registered_ids.append(room.id)

func remove_all_rooms() -> void:
	registered_positions.clear()
	for i in range(rooms.get_child_count(false)):
		var r = rooms.get_child(i)
		r.queue_free()
