extends Resource
class_name StatShard

@export var stat_name : String = ""
@export var image : Texture 

@export_category("pool info")

@export var weight : float = 1.0
@export var shop_cost : int = 100
@export var modulates : Dictionary[Modulate, int] = {}

func get_modulates(luck : int) -> Dictionary[Modulate, int]:
	var final_dict : Dictionary[Modulate, int] = get("modulates")
	for i in final_dict:
		match i.rarity:
			Modulate.RARITY.COMMON:
				final_dict[i] = clampi(final_dict[i] - (luck / 2), 0, 40)
			Modulate.RARITY.UNCOMMON:
				final_dict[i] = clampi(final_dict[i] - (luck / 3), 2, 30)
			Modulate.RARITY.EPIC:
				final_dict[i] = clampi(final_dict[i] + (luck / 2), 1, 25)
			Modulate.RARITY.LEGENDARY:
				final_dict[i] = clampi(final_dict[i] + (luck / 3), 1, 15)
			Modulate.RARITY.MYTHIC:
				final_dict[i] = clampi(final_dict[i] + (luck / 3), 1, 10)
	return final_dict
