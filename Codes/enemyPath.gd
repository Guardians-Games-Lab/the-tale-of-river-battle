extends PathFollow2D

@export var speed: float = 100.0
@onready var body = $Enemy

func _process(delta):
	progress += speed * delta

	# mantém posição
	if is_instance_valid(body):
		body.global_position = global_position

	# chegou no fim
	if progress_ratio >= 1.0:
		# 🔥 só dispara se ainda existir
		if is_instance_valid(body):
			body.escaped.emit()
		queue_free()
