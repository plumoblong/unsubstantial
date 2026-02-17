extends Node2D

@onready var main_screen : Node = $Main
@onready var options_screen : Node = $Options
@onready var statistics_screen : InventoryUI = $Statistics
@onready var restart_confirm_screen : Node = $RestartConfirm
@onready var chapter_info : RichTextLabel = $Main/ChapterInfo
@onready var restart_button : Button = $Main/Restart
@onready var stats_label : RichTextLabel = $Statistics/Stats

# Cached references
var player_stats : ItemStats
var player_essence : EssenceComponent
var chapter : ChapterManager

# Cached strings to reduce allocations
const BOLD_START : String = "[b][i]- "
const BOLD_END : String = " -[/i][/b]\n"
const ETHER_SUFFIX : String = "\n\n[i]ANOTHER BEGINNING"
const CHAPTER_PREFIX : String = "\n\n[i]CHAPTER "
const STAGE_PREFIX : String = " STAGE "

var screen : int = 0

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player_stats = _G.player.stats
	player_essence = _G.player.essence_component
	chapter = _G.game.chapter

func _process(_delta : float) -> void:
	if not visible: return
	if chapter == null: return
	
	if Input.is_action_just_pressed("escape"):
		if options_screen.screen == 0:
			screen = 0
	main_screen.visible = screen == 0
	options_screen.visible = screen == 1
	statistics_screen.visible = screen == 2
	restart_confirm_screen.visible = screen == 3

	var current_chapter = chapter.current
	if _G.game.in_ether:
		chapter_info.text = BOLD_START + current_chapter.chapter_name + BOLD_END + current_chapter.description + ETHER_SUFFIX
	else:
		chapter_info.text = BOLD_START + current_chapter.chapter_name + BOLD_END + current_chapter.description + CHAPTER_PREFIX + str(current_chapter.id) + STAGE_PREFIX + str(_G.game.stage)
	
	restart_button.disabled = _G.game.in_ether

#func _update_statistics() -> void:
	#

func continue_pressed() -> void:
	get_parent().hide()

func restart_pressed() -> void:
	screen = 3

func options_pressed() -> void:
	screen = 1

func exit_pressed() -> void:
	_G.change_scene("res://scene/menu.tscn")

func statistics_pressed() -> void:
	screen = 2
	statistics_screen.create_shard_grid()

func rest_yes_pressed() -> void:
	_G.change_scene("res://scene/game.tscn")

func rest_no_pressed() -> void:
	screen = 0
