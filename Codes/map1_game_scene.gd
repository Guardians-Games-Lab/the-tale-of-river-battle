extends Node2D

@export var current_map: String

var preview = null
var selected_tower_scene: PackedScene = null
var selected_tower_cost: int = 0

var current_pointer_pos: Vector2 = Vector2.ZERO

@onready var ground = get_tree().get_first_node_in_group("ground")
@onready var exclusion = get_tree().get_first_node_in_group("exclusion")
@onready var towers_node = get_node_or_null("Towers")
@onready var btn_cancel = get_node_or_null("CanvasLayerUI/BtnCancel")
@onready var btn_confirm = get_node_or_null("CanvasLayerUI/BtnConfirm")

var jogo_acabou: bool = false

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	add_to_group("game")
	Game.current_map = current_map
	Game.tocar_musica("fase")

	if btn_cancel:
		btn_cancel.hide()
		btn_cancel.pressed.connect(cancel_tower)

	if btn_confirm:
		btn_confirm.hide()
		btn_confirm.pressed.connect(confirm_tower)

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

	current_pointer_pos = get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2)

	if btn_cancel:
		btn_cancel.show()
	if btn_confirm:
		btn_confirm.show()
	print("🛠️ Modo construção ativado")

# =========================
# 🟡 PREVIEW
# =========================
func _process(_delta):
	if not preview:
		return

	var tile_pos = get_tile_position(current_pointer_pos)
	if tile_pos == Vector2i(-1, -1):
		preview.hide()
		if btn_confirm:
			btn_confirm.disabled = true
		return

	preview.show()
	preview.global_position = ground.to_global(ground.map_to_local(tile_pos))

	var valido = is_valid_tile(tile_pos)
	preview.set_preview_valid(valido)

	if btn_confirm:
		btn_confirm.disabled = not valido

# =========================
# 🖱️ INPUT
# =========================
func _unhandled_input(event):
	if jogo_acabou or Game.Health <= 0:
		return

	if event.is_action_pressed("ui_cancel"):
		cancel_tower()
		return

	if not preview:
		return

	# Toque/clique posiciona o preview, arrasto e mouse também
	if event is InputEventScreenTouch and event.pressed:
		current_pointer_pos = get_canvas_transform().affine_inverse() * event.position
	elif event is InputEventMouseButton and event.pressed:
		current_pointer_pos = get_canvas_transform().affine_inverse() * event.position

	# Desktop: clique direito cancela
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_tower()

# =========================
# ✅ CONFIRMAR COLOCAÇÃO
# =========================
func confirm_tower():
	if not preview:
		return

	var tile_pos = get_tile_position(current_pointer_pos)

	if not is_valid_tile(tile_pos):
		print("⚠️ Posição inválida!")
		return

	if not Game.spend_gold(selected_tower_cost):
		print("⚠️ Sem ouro suficiente!")
		return

	place_tower(tile_pos)

# =========================
# 🏗️ COLOCAR TORRE
# =========================
func place_tower(tile_pos: Vector2i):
	if towers_node == null:
		return

	var tower = selected_tower_scene.instantiate()
	tower.can_attack = true
	tower.show_range = false

	towers_node.add_child(tower)
	tower.global_position = ground.to_global(ground.map_to_local(tile_pos))
	tower.clear_preview_state()

	cancel_tower()
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

	if btn_cancel:
		btn_cancel.hide()
	if btn_confirm:
		btn_confirm.hide()
		btn_confirm.disabled = false
	print("❌ Construção cancelada")

# =========================
# 🧭 COORDENADAS
# =========================
func get_tile_position(world_pos: Vector2) -> Vector2i:
	if not ground:
		return Vector2i(-1, -1)
	return ground.local_to_map(ground.to_local(world_pos))

func is_valid_tile(tile_pos: Vector2i) -> bool:
	if ground == null or exclusion == null:
		return false
	if ground.get_cell_atlas_coords(tile_pos) == Vector2i(-1, -1):
		return false
	if exclusion.get_cell_atlas_coords(tile_pos) != Vector2i(-1, -1):
		return false

	var check_pos = ground.to_global(ground.map_to_local(tile_pos))
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = 12
	query.transform = Transform2D(0, check_pos)
	query.collide_with_bodies = true

	for r in space.intersect_shape(query):
		if r.collider != preview and r.collider.is_in_group("tower"):
			return false

	return true
