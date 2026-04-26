extends Node2D
class_name CrystalPiece

@onready var sprite    : Sprite2D     = $Sprite
@onready var stat_icon : Sprite2D     = $Icon
@onready var info      : Label        = $Info
@onready var anim      : AnimationPlayer = $Anim

var enabled         : bool     = false
var hovered         : bool     = false
var chosen_stat     : StatShard
var chosen_modulate : Modulate
var description     : String = "? ? ?"

## Called by CrystalChoose after both stat and modulate have been resolved.
func setup(shard: StatShard, mod: Modulate) -> void:
	chosen_stat     = shard
	chosen_modulate = mod
	
	if chosen_stat.image != null:
		stat_icon.texture = chosen_stat.image

	enabled = true
	

func _process(_delta: float) -> void:
	$Bound.mouse_filter = (
		Control.MOUSE_FILTER_PASS if enabled
		else Control.MOUSE_FILTER_IGNORE
	)

	if chosen_stat == null or not enabled:
		return

	$Rarity.frame              = chosen_modulate.rarity + (int(_G.config.ui_dark_mode) * 5)
	info.text                  = chosen_modulate.get_description()
	description                = _G.game.shard_picker.get_stat_change_text(chosen_modulate, true)
	$Info/Shadow.text          = info.text
	$Info/Shadow2.text         = info.text
	stat_icon.use_parent_material = _G.config.ui_dark_mode

	if hovered and Input.is_action_just_pressed("ui_press"):
		_on_selected()

	_update_positions()


func mouse_entered() -> void:
	if not enabled:
		return
	hovered = true
	anim.play("hover_in")
	_G.game.crystal_choose.description_text = description

func mouse_exited() -> void:
	hovered = false
	anim.play("hover_out")
	_G.game.crystal_choose.description_text = ". . ."
# ── private ──────────────────────────────────────────────────────────────────

func _on_selected() -> void:
	_G.player.stats.add_stat(chosen_modulate, chosen_stat.image)
	_G.current_run.crystals_collected += 1
	_G.game.crystal_choose.end_choose()
	

func _update_positions() -> void:
	var coeff := _R.get_aspect_coefficient()
	$Glow2.scale  = Vector2(2.5, 2.5) * coeff
	$Sprite.scale = Vector2.ONE * coeff
	$Bound.size   = Vector2i(64, 128) * coeff
	$Bound.position = Vector2(0.0, 0.0) - $Bound.size / 2
