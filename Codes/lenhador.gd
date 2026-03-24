extends StaticBody2D

var Bullet = preload("res://Assets/Towers/Machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 10

var targets: Array = []
var can_shoot := true

@onready var range_area: Area2D = $TowerRange
@onready var aim = $Aim


func _ready():
	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)


func _process(_delta):
	# limpa alvos inválidos
	
	
	targets = targets.filter(func(t): return is_instance_valid(t))

	if targets.is_empty():
		return

	var target = targets[0]

	# gira a mira
	var dir = target.global_position - aim.global_position
	aim.rotation = dir.angle()

	if can_shoot:
		shoot(target)


func shoot(target):
	can_shoot = false

	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = aim.global_position
	bullet.target = target
	bullet.damage = bullet_damage

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true



	

func _on_tower_range_body_exited(body: Node2D) -> void:
	print("Entrou:", body.name)
	if body in targets:
		targets.erase(body)# Replace with function body.
	

func _on_tower_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body) # Replace with function body.
