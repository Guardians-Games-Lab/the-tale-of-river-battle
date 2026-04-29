extends Node2D

# =========================
# 📂 REFERÊNCIAS
# =========================
var preview = null
var selected_tower: PackedScene

@onready var ground = get_tree().get_first_node_in_group("ground")
@onready var exclusion = get_tree().get_first_node_in_group("exclusion")
@onready var towers_node = get_node_or_null("Towers")
@onready var botao_pausa = get_node_or_null("CanvasLayerUI/PauseButton")
@onready var menu_pausa = get_node_or_null("MenuPause")
@onready var menu_game_over = get_node_or_null("MenuGameOver")

var jogo_acabou: bool = false 

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	add_to_group("game")
	
	# 👇 AVISANDO O AUTOLOAD: Pontos desta partida vão para a tabela do Mapa 1!
	Game.current_map = "mapa_1" 
	
	Game.reset_stats()
	
	if botao_pausa:
		botao_pausa.pressed.connect(_on_pause_btn_pressed) 
		
	Game.game_over.connect(_chamar_tela_game_over)

# =========================
# 💀 GAME OVER
# =========================
func _chamar_tela_game_over():
	jogo_acabou = true
	
	# 👇 GATILHO DA REDE LOCAL: Envia a pontuação para a sala ao morrer
	Game.submeter_score_lan()
	
	get_tree().paused = true 
	
	if menu_pausa:
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	
	if botao_pausa:
		botao_pausa.visible = false
	
	if menu_game_over:
		menu_game_over.visible = true

# =========================
# 🎯 SELECIONAR TORRE
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
# 🟡 ATUALIZAÇÃO (PREVIEW)
# =========================
func _process(_delta):
	if preview:
		var tile_pos = get_tile_position()
		var snapped_pos = ground.map_to_local(tile_pos)
		
		preview.global_position = ground.to_global(snapped_pos)
		preview.set_preview_valid(is_valid_tile())

# =========================
# 🧱 TILE POSITION
# =========================
func get_tile_position():
	var mouse_local = ground.to_local(get_global_mouse_position())
	return ground.local_to_map(mouse_local)

# =========================
# ✔️ VALIDAÇÃO DE POSIÇÃO
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
# 🔥 DETECTAR TORRE EXISTENTE
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
# 🖱️ CLIQUE E INPUTS
# =========================
func _input(event):
	if jogo_acabou or Game.Health <= 0:
		return
		
	if preview and event is InputEventMouseButton and event.pressed:
		if get_viewport().gui_get_hovered_control():
			return
		
		if is_valid_tile() and Game.spend_gold(20):
			place_tower()
		else:
			cancel_tower()
			
	if event.is_action_pressed("ui_cancel"):
		_on_pause_btn_pressed()

# =========================
# 🏗️ COLOCAR TORRE
# =========================
func place_tower():
	if towers_node == null:
		print("❌ ERRO: node Towers não encontrado")
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
# ❌ CANCELAR
# =========================
func cancel_tower():
	if preview:
		preview.queue_free()
	preview = null
	
# =========================
# ⏸️ MENU DE PAUSA
# =========================
func _on_pause_btn_pressed() -> void:
	if jogo_acabou:
		return
		
	if menu_pausa:
		menu_pausa._toggle_pause()