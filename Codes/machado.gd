extends CharacterBody2D

@export var speed: float = 250.0

var target = null
var damage: int = 10
var hit_confirmado := false

func _physics_process(delta):
	# 🛡️ TRAVA 1: Se o alvo sumiu do mapa, o machado some também
	if not is_instance_valid(target):
		queue_free()
		return

	# Agora é seguro acessar global_position
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	rotation = dir.angle()

	# 🛡️ TRAVA 2: Processamento de colisão limpo
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		# Verifica se o que batemos ainda existe e se é o nosso alvo
		if is_instance_valid(body) and body == target and not hit_confirmado:
			hit_confirmado = true 
			
			if body.has_method("take_damage"):
				body.take_damage(damage)
			
			queue_free()
			break # Sai do loop e para o script