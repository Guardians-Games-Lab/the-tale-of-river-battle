extends StaticBody2D

var Bullet = preload("res://Assets/Towers/Machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 5
@export var base_cost: int = 20

var recem_colocada: bool = false
var targets: Array = []
var can_shoot: bool = true
var can_attack: bool = true
var show_range: bool = false
var sell_value: int = 0
var mouse_na_torre: bool = false

# =========================
# ⬆️ SISTEMA DE UPGRADES
# =========================
var nivel_velocidade: int = 0
var nivel_range: int = 0
const MAX_UPGRADES: int = 3

var custo_velocidade_base: int = 25
var custo_range_base: int = 20

@onready var range_area: Area2D = $TowerRange
@onready var aim: Node2D = $Aim
@onready var menu_upgrade = $Upgrade
@onready var btn_vender: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoVender
@onready var btn_velocidade: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoVelocidade
@onready var btn_range: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoRange

func _ready():
	# =========================
	# 👻 PREVIEW / FANTASMA
	# =========================
	recem_colocada = true
	get_tree().process_frame.connect(func() : recem_colocada = false, CONNECT_ONE_SHOT)
	
	if not can_attack:
		input_pickable = false
		menu_upgrade.hide()
		menu_upgrade.process_mode = Node.PROCESS_MODE_DISABLED
		set_process_unhandled_input(false)
		return

	# Torre real — bloqueia input no frame que nasceu
	input_pickable = false

	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)
	menu_upgrade.hide()
	add_to_group("tower")

	sell_value = int(base_cost / 2.0)
	$TowerRange/CollisionShape2D.shape = $TowerRange/CollisionShape2D.shape.duplicate()

	btn_vender.pressed.connect(_on_btn_vender_pressed)
	btn_velocidade.pressed.connect(_on_btn_velocidade_pressed)
	btn_range.pressed.connect(_on_btn_range_pressed)
	atualizar_textos_upgrade()

	# Só libera o input no próximo frame, quando o toque de colocação já passou
	await get_tree().process_frame
	input_pickable = true

func _process(_delta):
	queue_redraw()
	if not can_attack: return

	targets = targets.filter(func(t): return is_instance_valid(t))
	if targets.is_empty(): return

	var target: Node2D = targets[0]
	if target == null: return

	var dir = target.global_position - global_position
	rotation = dir.angle()
	aim.rotation = 0
	menu_upgrade.global_rotation = 0

	if can_shoot:
		shoot(target)

# =========================
# 🖱️ CLIQUE / TOQUE NA TORRE
# =========================
func _input_event(viewport, event, shape_idx):
	if recem_colocada: return
	var game = get_tree().get_first_node_in_group("game")

	# Trava: se estiver colocando torre no mapa, não abre o menu
	if game and game.preview != null:
		return

	var pressionado: bool = (
		event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	) or (
		event is InputEventScreenTouch and event.pressed
	)

	if pressionado:
		get_viewport().set_input_as_handled()
		if menu_upgrade.visible:
			deselecionar()
		else:
			selecionar_torre()

# =========================
# 🌍 TOQUE FORA (FECHAR MENU)
# =========================
func _unhandled_input(event):
	if not can_attack: return

	var pressionado: bool = false
	if event is InputEventScreenTouch and event.pressed:
		pressionado = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressionado = true

	if pressionado and menu_upgrade.visible:
		var touch_pos: Vector2
		if event is InputEventScreenTouch or event is InputEventMouseButton:
			touch_pos = get_canvas_transform().affine_inverse() * event.position
		
		var distancia = global_position.distance_to(touch_pos)
		var raio = 64
		if distancia > raio:
			deselecionar()

		
# =========================
# 🎨 DESENHOS E PREVIEW
# =========================
func _draw():
	if not show_range: return
	var shape = $TowerRange/CollisionShape2D.shape
	if shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, Color(0.13, 0.13, 0.13, 0.08))
		draw_arc(Vector2.ZERO, shape.radius, 0, TAU, 64, Color(0.13, 0.13, 0.13, 0.4), 2)

func set_preview_valid(is_valid: bool) -> void:
	var color = Color(0, 1, 0, 0.5) if is_valid else Color(1, 0, 0, 0.5)
	for child in get_children():
		if child is Sprite2D:
			child.modulate = color

func clear_preview_state() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.modulate = Color(1, 1, 1, 1)

# =========================
# 🔫 ATAQUE E MECÂNICAS
# =========================
func shoot(target):
	if not is_instance_valid(target): return
	can_shoot = false
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = aim.global_position
	bullet.target = target
	bullet.damage = bullet_damage
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func selecionar_torre():
	get_tree().call_group("tower", "deselecionar")
	menu_upgrade.show()
	show_range = true
	queue_redraw()

func deselecionar():
	if menu_upgrade.visible:
		menu_upgrade.hide()
		show_range = false
		queue_redraw()

func atualizar_textos_upgrade():
	if nivel_velocidade < MAX_UPGRADES:
		btn_velocidade.text = "Speed: $" + str(custo_velocidade_base * (nivel_velocidade + 1))
	else:
		btn_velocidade.text = "Speed MÁX"
		btn_velocidade.disabled = true

	if nivel_range < MAX_UPGRADES:
		btn_range.text = "Range: $" + str(custo_range_base * (nivel_range + 1))
	else:
		btn_range.text = "Range MÁX"
		btn_range.disabled = true

func _on_btn_vender_pressed():
	Game.add_gold(sell_value)
	queue_free()

func _on_tower_range_body_entered(body: Node2D) -> void:
	if not can_attack: return
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body)

func _on_tower_range_body_exited(body: Node2D) -> void:
	if body in targets: targets.erase(body)

func _on_btn_velocidade_pressed():
	if nivel_velocidade >= MAX_UPGRADES: return
	var custo_atual = custo_velocidade_base * (nivel_velocidade + 1)
	if Game.spend_gold(custo_atual):
		nivel_velocidade += 1
		fire_rate -= 0.2
		if fire_rate < 0.1: fire_rate = 0.1
		base_cost += custo_atual
		sell_value = int(base_cost / 2.0)
		atualizar_textos_upgrade()

func _on_btn_range_pressed():
	if nivel_range >= MAX_UPGRADES: return
	var custo_atual = custo_range_base * (nivel_range + 1)
	if Game.spend_gold(custo_atual):
		nivel_range += 1
		var shape = $TowerRange/CollisionShape2D.shape as CircleShape2D
		shape.radius += 30.0
		base_cost += custo_atual
		sell_value = int(base_cost / 2.0)
		atualizar_textos_upgrade()
		queue_redraw()

func ativar_torre():
	can_attack = true
	input_pickable = true
	add_to_group("tower")

	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)
	menu_upgrade.hide()

	sell_value = int(base_cost / 2.0)
	$TowerRange/CollisionShape2D.shape = $TowerRange/CollisionShape2D.shape.duplicate()

	btn_vender.pressed.connect(_on_btn_vender_pressed)
	btn_velocidade.pressed.connect(_on_btn_velocidade_pressed)
	btn_range.pressed.connect(_on_btn_range_pressed)
	atualizar_textos_upgrade()
	
	
