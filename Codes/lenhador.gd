extends StaticBody2D

var Bullet = preload("res://Assets/Towers/Machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 10

var targets: Array = []
var can_shoot := true

@onready var range_area: Area2D = $TowerRange
@onready var aim: Node2D = $Aim

func _ready():
	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)


func _process(_delta):
	# Limpa alvos inválidos
	targets = targets.filter(func(t): return is_instance_valid(t))

	# Checa se ainda há alvos
	if targets.is_empty():
		return

	# Pega o primeiro alvo seguro
	var target: Node2D = null
	for t in targets:
		if is_instance_valid(t):
			target = t
			break

	if target == null:
		return

	# Calcula direção e gira torre
	var dir = target.global_position - global_position
	rotation = dir.angle()

	# Mira sempre fixa relativa à torre
	aim.rotation = 0

	if can_shoot:
		shoot(target)


func shoot(target):
	can_shoot = false

	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)

	# posição da bala no ponto da mira
	bullet.global_position = aim.global_position
	bullet.target = target
	bullet.damage = bullet_damage

	# Espera o tempo de fire_rate para poder atirar novamente
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func _on_tower_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body)


func _on_tower_range_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)
