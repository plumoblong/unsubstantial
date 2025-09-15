extends CSGShape3D
class_name ChapterGeometry

@export var chapter_material : ChapterMaterials.MAT = ChapterMaterials.MAT.WALL

func _ready() -> void:
	material_override = _G.game.chapter.current.get_material(chapter_material)
	#await get_tree().create_timer(10.0).timeout
	#generate_body()
	#
#func generate_body() -> void:
	#var mesh = get_meshes()
#
	#var shape = mesh[1].create_trimesh_shape()
	#var body : StaticBody3D = StaticBody3D.new()
	#var collision : CollisionShape3D = CollisionShape3D.new()
	#collision.shape = shape
	#
	#body.add_child(collision)
	#body.global_transform = global_transform
