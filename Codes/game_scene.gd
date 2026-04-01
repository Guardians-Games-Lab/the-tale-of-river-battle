extends Node2D

var preview = null
var selected_tower: PackedScene

@onready var ground = get_tree().get_first_node_in_group("ground")
@onready var exclusion = get_tree().get_first_node_in_group("exclusion")
@onready var towers_node = get_node("Towers")


func _ready():
	add_to_group("game")


# =========================
# 🎯 Selecionar torre
# =========================
func start_build_mode(scene):
	selected_tower = scene
	
	if preview:
		preview.queue_free()
	
	preview = selected_tower.instantiate()
	add_child(preview)
	
	preview.can_attack = false
	preview.show_range = true
	preview.clear_preview_state()


# =========================
# 🟡 Atualização
# =========================
func _process(delta):
	if preview:
		var tile_pos = get_tile_position()
		var snapped_pos = ground.map_to_local(tile_pos)
		
		preview.global_position = ground.to_global(snapped_pos)
		preview.set_preview_valid(is_valid_tile())


# =========================
# 🧱 Tile
# =========================
func get_tile_position():
	var mouse_local = ground.to_local(get_global_mouse_position())
	return ground.local_to_map(mouse_local)


# =========================
# ✔ Validação
# =========================
func is_valid_tile() -> bool:
	if ground == null or exclusion == null:
		return false
	
	var tile_pos = get_tile_position()
	
	var ground_tile = ground.get_cell_atlas_coords(tile_pos)
	var exclusion_tile = exclusion.get_cell_atlas_coords(tile_pos)
	
	if ground_tile == Vector2i(-1, -1):
		return false
	
	if exclusion_tile != Vector2i(-1, -1):
		return false
	
	if has_tower_on_position():
		return false
	
	return true


# =========================
# 🔥 Detectar torre
# =========================
func has_tower_on_position() -> bool:
	var space = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = 12
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, preview.global_position)
	query.collide_with_bodies = true
	
	var result = space.intersect_shape(query)
	
	for r in result:
		var obj = r.collider
		
		if obj != preview and obj.is_in_group("tower"):
			return true
	
	return false


# =========================
# 🖱️ Clique
# =========================
func _input(event):
	if preview and event is InputEventMouseButton and event.pressed:
		
		if get_viewport().gui_get_hovered_control():
			return
		
		if is_valid_tile() and Game.spend_gold(20):
			place_tower()
		else:
			cancel_tower()


# =========================
# 🏗️ Colocar torre
# =========================
func place_tower():
	if towers_node == null:
		print("ERRO: node Towers não encontrado")
		return
	
	var tower = selected_tower.instantiate()
	
	var tile_pos = get_tile_position()
	var snapped_pos = ground.map_to_local(tile_pos)
	
	tower.global_position = ground.to_global(snapped_pos)
	tower.can_attack = true
	tower.show_range = false
	tower.clear_preview_state()
	
	towers_node.add_child(tower)
	
	preview.queue_free()
	preview = null


# =========================
# ❌ Cancelar
# =========================
func cancel_tower():
	if preview:
		preview.queue_free()
	preview = null
	
