extends Node3D

@export var amplitude : float = 1.0
@export var frequency : float = 1.0

@export_category("optional")
@export var movement_component : MovementComponent
@export var time_offset : float = 0.0

func _physics_process(_delta : float) -> void:
	if movement_component == null:
		global_position.y += _G.sine_movement(amplitude, frequency, time_offset)
