extends Node2D

var in_transition : bool = false

#comment this for test
#func _process(_delta : float) -> void:
	#$Essence.text = str(_G.player.essence_component.essence)
	
func reset()-> void:
	$ItemButton.shatter()
	$ItemButton2.shatter()
	$ItemButton3.shatter()
	$ShatteredCrystal1.visible = $ItemButton.shattered
	$ShatteredCrystal2.visible = $ItemButton2.shattered
	$ShatteredCrystal3.visible = $ItemButton3.shattered
	
	$ShatteredCrystal1.set_essence()
	$ShatteredCrystal2.set_essence()
	$ShatteredCrystal3.set_essence()
	$ShatteredCrystal1/Sprite2D.modulate = Color.DARK_GRAY
	$ShatteredCrystal2/Sprite2D.modulate = Color.DARK_GRAY
	$ShatteredCrystal3/Sprite2D.modulate = Color.DARK_GRAY
	$ShatteredCrystal3/Sprite2D2.modulate = Color.DARK_GRAY
	$ShatteredCrystal3/Sprite2D2.modulate = Color.DARK_GRAY
	$ShatteredCrystal3/Sprite2D2.modulate = Color.DARK_GRAY
	$ShatteredCrystal1.modulate = Color.DARK_GRAY
	$ShatteredCrystal2.modulate = Color.DARK_GRAY
	$ShatteredCrystal3.modulate = Color.DARK_GRAY
	$ItemButton.elemental_alpha = 0.0
	$ItemButton2.elemental_alpha = 0.0
	$ItemButton3.elemental_alpha = 0.0
	$ColorRect2.modulate = Color.TRANSPARENT
	$ItemButton.modulate = Color.GRAY
	$ItemButton/Item.modulate = Color(1,1,1,0)
	$ItemButton2.modulate = Color.GRAY
	$ItemButton2/Item.modulate = Color(1,1,1,0)
	$ItemButton3.modulate = Color.GRAY
	$ItemButton3/Item.modulate = Color(1,1,1,0)
	in_transition = false

func fade() -> void:
	in_transition = true
	_G.tween($ColorRect2, "modulate", Color(1,1,1,1), 0.9)
	await get_tree().create_timer(1.0).timeout
	reset()
	_G.flare_screen()
	_G.game.in_transition = false

func item_chosen1() -> void:
	fade()
	_G.tween($ItemButton, "modulate", Color.TRANSPARENT, 0.9)
	_G.tween($ItemButton2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton3, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal3, "modulate", Color.TRANSPARENT, 0.25)

func item_chosen2() -> void:
	fade()
	_G.tween($ItemButton, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton2, "modulate", Color.TRANSPARENT, 0.9)
	_G.tween($ItemButton3, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal1, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal3, "modulate", Color.TRANSPARENT, 0.25)

func item_chosen3() -> void:
	fade()
	_G.tween($ItemButton, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton3, "modulate", Color.TRANSPARENT, 0.9)
	_G.tween($ShatteredCrystal1, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal2, "modulate", Color.TRANSPARENT, 0.25)

func shattered_crystal_1_pressed()-> void:
	fade()
	_G.tween($ItemButton2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton3, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal1, "modulate", Color.TRANSPARENT, 0.9)
	_G.tween($ShatteredCrystal2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal3, "modulate", Color.TRANSPARENT, 0.25)


func shattered_crystal_2_pressed()-> void:
	fade()
	_G.tween($ItemButton, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton3, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal1, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal2, "modulate", Color.TRANSPARENT, 0.9)
	_G.tween($ShatteredCrystal3, "modulate", Color.TRANSPARENT, 0.25)

func shattered_crystal_3_pressed() -> void:
	fade()
	_G.tween($ItemButton, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ItemButton2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal1, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal2, "modulate", Color.TRANSPARENT, 0.25)
	_G.tween($ShatteredCrystal3, "modulate", Color.TRANSPARENT, 0.9)
