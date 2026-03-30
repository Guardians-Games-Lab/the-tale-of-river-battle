extends StaticBody2D

var Bullet = preload("res://Assets/Towers/Machado.tscn")

@export var fire_rate: float = 1.0
@export var bullet_damage: int = 10

var targets: Array = []
var can_shoot := true
var can_attack := true

var show_range := false


@onready var range_area: Area2D = $TowerRange
@onready var aim: Node2D = $Aim


func _ready():
	range_area.body_entered.connect(_on_tower_range_body_entered)
	range_area.body_exited.connect(_on_tower_range_body_exited)
	add_to_group("tower")


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

	if can_shoot:
		shoot(target)


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


func _on_tower_range_body_entered(body: Node2D) -> void:
	if not can_attack:
		return
	
	if body.is_in_group("enemy") and not targets.has(body):
		targets.append(body)


func _on_tower_range_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)
