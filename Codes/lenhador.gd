extends StaticBody2D

var Bullet = preload("res://Assets/Towers/machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 5
@export var base_cost: int = 20

var targets: Array = []
var can_shoot := true
var can_attack := true
var show_range := false
var sell_value: int = 0
var mouse_na_torre := false

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
# 👇 Caminho atualizado! Lembre de renomear o nó no Godot para BotaoVelocidade
@onready var btn_velocidade: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoVelocidade
@onready var btn_range: Button = $Upgrade/PainelDeUpgrade/MargemDoPainel/ContainerDosButoes/BotaoRange


func _ready():
	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)
	
	# Esconde o menu de upgrade logo que a torre é colocada no mapa
	menu_upgrade.hide()
	mouse_entered.connect(func(): mouse_na_torre = true)
	mouse_exited.connect(func(): mouse_na_torre = false)
	add_to_group("tower")
	
	# CÁLCULO DE VENDA
	sell_value = int(base_cost / 2.0) 
	
	# O SEGREDO DO RANGE: Torna o círculo desta torre único!
	$TowerRange/CollisionShape2D.shape = $TowerRange/CollisionShape2D.shape.duplicate()
	
	# Conecta os cliques aos botões
	btn_vender.pressed.connect(_on_btn_vender_pressed)
	btn_velocidade.pressed.connect(_on_btn_velocidade_pressed)
	btn_range.pressed.connect(_on_btn_range_pressed)
	
	# Atualiza o texto dos botões logo que a torre nasce
	atualizar_textos_upgrade()

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

	# 🛡️ Verifica se o alvo ainda existe no momento do disparo
	if not is_instance_valid(target):
		return


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
	print("🌲 Lenhador selecionado! Abrindo menu de Upgrade.")

func deselecionar():
	if menu_upgrade.visible:
		menu_upgrade.hide()
		show_range = false
		queue_redraw()


# =========================
# 📝 ATUALIZAR UI DOS UPGRADES
# =========================
func atualizar_textos_upgrade():
	if nivel_velocidade < MAX_UPGRADES:
		var proximo_custo = custo_velocidade_base * (nivel_velocidade + 1)
		btn_velocidade.text = "Speed: $" + str(proximo_custo)
	else:
		btn_velocidade.text = "Speed MÁX"
		btn_velocidade.disabled = true

	if nivel_range < MAX_UPGRADES:
		var proximo_custo = custo_range_base * (nivel_range + 1)
		btn_range.text = "Range: $" + str(proximo_custo)
	else:
		btn_range.text = "Range MÁX"
		btn_range.disabled = true


# =========================
# 💰 VENDER TORRE
# =========================
func _on_btn_vender_pressed():
	Game.add_gold(sell_value)
	print("💸 Torre vendida! Dinheiro recuperado: $", sell_value, " | Dinheiro Total: $", Game.Gold)
	queue_free()


func _on_tower_range_body_entered(body: Node2D) -> void:
	if not can_attack:
		return
	
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body)


func _on_tower_range_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)


# =========================
# ⚡ UPGRADE DE VELOCIDADE
# =========================
func _on_btn_velocidade_pressed():
	if nivel_velocidade >= MAX_UPGRADES: return
	
	var custo_atual = custo_velocidade_base * (nivel_velocidade + 1)
	
	if Game.spend_gold(custo_atual):
		nivel_velocidade += 1
		
		# Reduz o tempo de recarga em 0.2 segundos
		fire_rate -= 0.2 
		
		# Trava de segurança para não atirar rápido demais e bugar a física
		if fire_rate < 0.1:
			fire_rate = 0.1
		
		base_cost += custo_atual
		sell_value = int(base_cost / 2.0)
		
		atualizar_textos_upgrade()
		print("⚡ Upgrade de Velocidade! Nível: ", nivel_velocidade, " | Novo Fire Rate: ", fire_rate)


# =========================
# 🔭 UPGRADE DE RANGE
# =========================
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
		print("🔭 Upgrade de Range! Nível: ", nivel_range, " | Novo Raio: ", shape.radius)
