extends Node2D

var preview = null
var selected_tower_scene: PackedScene = null
var selected_tower_cost: int = 0

var current_pointer_pos: Vector2 = Vector2.ZERO

@onready var ground = get_tree().get_first_node_in_group("ground")
@onready var exclusion = get_tree().get_first_node_in_group("exclusion")
@onready var towers_node = get_node_or_null("Towers")
@onready var btn_cancel = get_node_or_null("CanvasLayerUI/BtnCancel") # 👈 sem o $

var jogo_acabou: bool = false

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	add_to_group("game")
	Game.tocar_musica("fase")
	if btn_cancel:
		btn_cancel.hide()
		btn_cancel.pressed.connect(cancel_tower)

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

	# Posição inicial no centro da tela
	current_pointer_pos = get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2)

	if btn_cancel:
		btn_cancel.show()
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
		return

	preview.show()
	preview.global_position = ground.to_global(ground.map_to_local(tile_pos))
	preview.set_preview_valid(is_valid_tile(tile_pos))

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

	# Rastreia posição do dedo durante o arrasto
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		current_pointer_pos = get_canvas_transform().affine_inverse() * event.position

	# Coloca a torre no RELEASE (evita vazar o toque do Panel)
	var soltou: bool = false
	if event is InputEventScreenTouch and not event.pressed:
		soltou = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		soltou = true

	if soltou:
		get_viewport().set_input_as_handled()
		var tile_pos = get_tile_position(current_pointer_pos)
		if is_valid_tile(tile_pos) and Game.spend_gold(selected_tower_cost):
			place_tower(tile_pos)
		else:
			cancel_tower()

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
	tower.set_deferred("can_attack", true)

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
