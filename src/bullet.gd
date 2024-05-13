extends Node3D
class_name Bullet

var speed : float = 80.0
var direction : Vector3
var creator

func _ready():
	$ShootSFX.pitch_scale = randf_range(0.80, 1.20)
	await get_tree().create_timer(9.0).timeout
	queue_free()
	

func _physics_process(delta):
	position += (direction * speed) * delta

func query_body_entered(body):
	if body is CSGCombiner3D:
		queue_free()
	elif body is Enemy:
		if body != creator and creator is LocalPlayer:
			creator.crosshair_target_shot()
			creator.invincibility(1)
			if creator.alive:
				creator.add_score(body.bounty)
				body.die()
				creator.invincibility(1)
			queue_free()
	elif body is LocalPlayer:
		if body != creator:
			if creator.alive and not body.invincible:
				body.die()
			queue_free()
