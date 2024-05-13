extends Node

@export var target_node_path : NodePath
@onready var target := get_node(target_node_path)

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var number_of_enemies : int = 0

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	number_of_enemies = get_child_count()
	if global.debug:
		if Input.is_action_just_pressed("f3"):
			for n in range(0, number_of_enemies):
				get_child(n).queue_free()
	else:
		if number_of_enemies == 0:
			end_game()

func end_game():
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scenes/end_of_demo.tscn")
