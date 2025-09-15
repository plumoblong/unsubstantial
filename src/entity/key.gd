extends Area3D

func _ready() -> void:
	_G.rng.randomize()
	$AnimationPlayer.play("idle")
	$Sprite3D.frame = _G.rng.randi_range(0, 15)

func body_entered(body : Player) -> void:
	if body.has_key: return
	body.has_key = true
	_G.player.hud.objective = "Find the Exit"
	_G.player.knock_component.knock(Vector3(global_position.x, _G.player.global_position.y, global_position.z), 16.0)
	_G.game.chat.add_message("You found the key.", Color.YELLOW)
	$CollisionShape3D.disabled = true
	collect()

func collect() -> void:
	$AnimationPlayer.play("collect")
	await get_tree().create_timer(3.0).timeout
	queue_free()
