extends Node2D

var preview = null
var selected_tower_scene: PackedScene = null
var selected_tower_cost: int = 0

# Variável para rastrear o dedo/mouse perfeitamente no celular
var current_pointer_pos: Vector2 = Vector2.ZERO 
@onready var ground = get_tree().get_first_node_in_group("ground")
@onready var exclusion = get_tree().get_first_node_in_group("exclusion")
@onready var towers_node = get_node_or_null("Towers")

var jogo_acabou: bool = false

func _ready():
	add_to_group("game")
	Game.tocar_musica("fase")
# =========================
# 🎯 INICIAR MODO DE CONSTRUÇÃO
# =========================
func start_build_mode(scene: PackedScene, cost: int):
	if preview:
		cancel_tower()
	
	selected_tower_scene = scene
	selected_tower_cost = cost
	
	preview = scene.instantiate()
	preview.can_attack = false
	add_child(preview)
	
	preview.show_range = true
	preview.clear_preview_state()
	
	# Puxa a posição inicial para o centro da tela para não nascer no canto
	current_pointer_pos = get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2)
	print("🛠️ Modo construção ativado")

# =========================
# 🟡 PREVIEW (MOVIMENTAÇÃO E VALIDAÇÃO)
# =========================
func _process(_delta):
	if not preview: 
		return
	
	var tile_pos = get_tile_position(current_pointer_pos)
	if tile_pos == Vector2i(-1, -1):
		preview.hide() # Esconde se estiver totalmente fora do mapa
		return
	
	preview.show()
	var local_pos = ground.map_to_local(tile_pos)
	preview.global_position = ground.to_global(local_pos)
	
	preview.set_preview_valid(is_valid_tile(tile_pos))

# =========================
# 🖱️ INPUT - CLIQUE PARA COLOCAR (Rastreio Perfeito)
# =========================
func _unhandled_input(event):
	if jogo_acabou or Game.Health <= 0:
		return
	
	if event.is_action_pressed("ui_cancel"):
		cancel_tower()
		return

	if not preview:
		return

	# 1. RASTREIA A POSIÇÃO EXATA DO DEDO (Ignora UI e resolve o bug de offset)
	if event is InputEventScreenDrag or event is InputEventScreenTouch or event is InputEventMouseMotion:
		# Converte a coordenada da tela do celular para o mundo 2D
		current_pointer_pos = get_canvas_transform().affine_inverse() * event.position

	# 2. SE APERTOU A TELA, TENTA CONSTRUIR
	var pressionado: bool = false
	if event is InputEventScreenTouch and event.pressed:
		pressionado = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressionado = true

	if pressionado:
		var tile_pos = get_tile_position(current_pointer_pos)
		if is_valid_tile(tile_pos) and towers_node != null:  # ← verifica towers_node antes
			if Game.spend_gold(selected_tower_cost):
				place_tower(tile_pos)
# =========================
# 🏗️ COLOCAR TORRE
# =========================
func place_tower(tile_pos: Vector2i):
	if towers_node == null: return
		
	var tower = selected_tower_scene.instantiate()
	tower.can_attack = false
	tower.show_range = false

	towers_node.add_child(tower)

	var snapped_pos = ground.map_to_local(tile_pos)
	tower.global_position = ground.to_global(snapped_pos)
	tower.clear_preview_state()

	cancel_tower()
	tower.call_deferred("ativar_torre")  # só isso, sem set_deferred
	print("✅ Torre colocada em: ", tower.global_position)

# =========================
# ❌ CANCELAR
# =========================
func cancel_tower():
	if preview:
		preview.queue_free()
		preview = null
	selected_tower_scene = null
	selected_tower_cost = 0

# =========================
# 🧭 FUNÇÕES AUXILIARES DE COORDENADAS
# =========================
func get_tile_position(world_pos: Vector2) -> Vector2i:
	if not ground: return Vector2i(-1, -1)
	var local_pos = ground.to_local(world_pos)
	return ground.local_to_map(local_pos)

func is_valid_tile(tile_pos: Vector2i) -> bool:
	if ground == null or exclusion == null: return false
	
	if ground.get_cell_atlas_coords(tile_pos) == Vector2i(-1, -1): return false
	if exclusion.get_cell_atlas_coords(tile_pos) != Vector2i(-1, -1): return false
	
	# Verifica colisão com outra torre na exata posição central do tile
	var snapped_pos = ground.map_to_local(tile_pos)
	var check_pos = ground.to_global(snapped_pos)
	
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = 12
	query.transform = Transform2D(0, check_pos)
	query.collide_with_bodies = true
	
	var result = space.intersect_shape(query)
	for r in result:
		if r.collider != preview and r.collider.is_in_group("tower"):
			return false
			
	return true
