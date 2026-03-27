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
	
	preview.process_mode = Node.PROCESS_MODE_DISABLED
	preview.modulate = Color(1,1,1,0.5)


# =========================
# 🟡 Atualização
# =========================
func _process(delta):
	if preview:
		var tile_pos = get_tile_position()
		var snapped_pos = ground.map_to_local(tile_pos)
		
		preview.global_position = ground.to_global(snapped_pos)
		update_preview_color()


# =========================
# 🧱 Pega tile corretamente
# =========================
func get_tile_position():
	var mouse_local = ground.to_local(get_global_mouse_position())
	return ground.local_to_map(mouse_local)


# =========================
# 🎨 Cor dinâmica
# =========================
func update_preview_color():
	if preview == null:
		return
	
	if is_valid_tile():
		preview.modulate = Color(0, 1, 0, 0.5)
	else:
		preview.modulate = Color(1, 0, 0, 0.5)


# =========================
# ✔ Validação correta
# =========================
func is_valid_tile() -> bool:
	if ground == null or exclusion == null:
		return false
	
	var tile_pos = get_tile_position()
	
	var ground_tile = ground.get_cell_atlas_coords(tile_pos)
	var exclusion_tile = exclusion.get_cell_atlas_coords(tile_pos)
	
	return ground_tile != Vector2i(-1, -1) and exclusion_tile == Vector2i(-1, -1)


# =========================
# 🖱️ Clique
# =========================
func _input(event):
	if preview and event is InputEventMouseButton and event.pressed:
		
		if get_viewport().gui_get_hovered_control():
			return
		
		if is_valid_tile():
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
