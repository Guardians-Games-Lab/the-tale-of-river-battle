extends StaticBody2D

var Bullet = preload("res://Assets/Towers/Machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 10
@export var base_cost: int = 20

var targets: Array = []
var can_shoot := true
var can_attack := true
var show_range := false
var sell_value: int = 0
var mouse_na_torre := false


@onready var range_area: Area2D = $TowerRange
@onready var aim: Node2D = $Aim
@onready var menu_upgrade = $Upgrade
@onready var btn_vender: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoVender

func _ready():
	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)
	
	# Esconde o menu de upgrade logo que a torre é colocada no mapa
	menu_upgrade.hide()
	mouse_entered.connect(func(): mouse_na_torre = true)
	mouse_exited.connect(func(): mouse_na_torre = false)
	add_to_group("tower")
	
	# 👇 CÁLCULO DE VENDA E CONEXÃO DO BOTÃO
	# Usa int() para garantir que não teremos moedas quebradas (ex: 20 / 2 = 10)
	sell_value = int(base_cost / 2.0) 
	
	# Conecta o clique do botão à nossa nova função
	btn_vender.pressed.connect(_on_btn_vender_pressed)


func _process(_delta):
	queue_redraw()

	if not can_attack:
		return
	
	targets = targets.filter(func(t): return is_instance_valid(t))

	if targets.is_empty():
		return

	var target: Node2D = null
	for t in targets:
		if is_instance_valid(t):
			target = t
			break

	if target == null:
		return

	var dir = target.global_position - global_position
	rotation = dir.angle()

	aim.rotation = 0
	menu_upgrade.global_rotation = 0 # Mantém o menu de pé, ignorando o giro do pai!

	if can_shoot:
		shoot(target)


# =========================
# 🖱️ CLIQUE NA TORRE (ABRIR MENU)
# =========================
func _input_event(viewport, event, shape_idx):
	# Mudamos para 'event.pressed' (quando o dedo TOCA na tela)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		
		if menu_upgrade.visible:
			deselecionar()
			print("🌲 Lenhador: Fechou o menu (Toggle)")
		else:
			selecionar_torre()
			print("🌲 Lenhador: Abriu o menu (Toggle)")

# =========================
# 🌍 CLIQUE FORA (FECHAR TUDO)
# =========================
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		if menu_upgrade.visible and not mouse_na_torre:
			deselecionar()
			print("❌ Toque fora da torre detectado. Fechando Upgrade.")

# =========================
# 🎨 RANGE (FIXO)
# =========================
func _draw():
	if not show_range:
		return
	
	var shape = $TowerRange/CollisionShape2D.shape
	
	if shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, Color(0.13, 0.13, 0.13, 0.08))
		draw_arc(Vector2.ZERO, shape.radius, 0, TAU, 64, Color(0.13, 0.13, 0.13, 0.4), 2)


# =========================
# 🎨 COR DO PREVIEW (SÓ SPRITE)
# =========================
func set_preview_valid(is_valid: bool) -> void:
	var color := Color(0, 1, 0, 0.5) if is_valid else Color(1, 0, 0, 0.5)

	for child in get_children():
		if child is Sprite2D:
			child.modulate = color


func clear_preview_state() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.modulate = Color(1, 1, 1, 1)

func shoot(target):
	can_shoot = false

	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = aim.global_position
	bullet.target = target
	bullet.damage = bullet_damage

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func selecionar_torre():
	# 1. Avisa todas as outras torres para fecharem seus menus de upgrade
	get_tree().call_group("tower", "deselecionar")
	
	# 2. Abre o menu DESTA torre
	menu_upgrade.show()
	
	# 3. Liga o desenho do range
	show_range = true 
	queue_redraw()
	
	print("🌲 Lenhador selecionado! Abrindo menu de Upgrade.")

func deselecionar():
	# Só tenta esconder se estiver aberto
	if menu_upgrade.visible:
		menu_upgrade.hide()
		show_range = false
		queue_redraw()

# =========================
# 💰 VENDER TORRE
# =========================
func _on_btn_vender_pressed():
	# 1. Devolve o dinheiro usando o Autoload
	Game.add_gold(sell_value)
	
	# 2. Print de segurança para o Console
	print("💸 Torre vendida! Dinheiro recuperado: $", sell_value, " | Dinheiro Total: $", Game.Gold)
	
	# 3. Deleta a torre do mapa
	queue_free()

func _on_tower_range_body_entered(body: Node2D) -> void:
	if not can_attack:
		return
	
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body)


func _on_tower_range_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)
