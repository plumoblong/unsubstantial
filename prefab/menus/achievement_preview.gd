extends Node2D
class_name AchievementPreview

@export var achievement : Achievement
@export var check_id : _G.achievement 

@export var show_desc : bool = true
@export var show_name : bool = false

var locked : bool = true
const LOCKED_IMAGE = preload("res://images/achievement/locked.png")

func _process(_delta : float) -> void:
	#if _G.save.achieved.has(check_id):
		#locked = false
	#else:
		#locked = true
	#
	if locked:
		if show_desc:
			$Description.text = achievement.description
		else:
			$Description.text = "? ? ?"
		
		if show_name:
			$Name.text = achievement.name
		else:
				$Name.text = "? ? ?"
		$Icon.set_texture(LOCKED_IMAGE)
	else:
		$Description.text = achievement.description
		$Name.text = achievement.name
		$Icon.set_texture(achievement.image)
