extends CharacterBody2D

@export var speed: float = 250.0

var target = null
var damage: int = 10
var hit_confirmado := false

func _physics_process(delta):
	# 1. Segurança: Se o alvo sumir por outro motivo, o machado some
	if not is_instance_valid(target):
		queue_free()
		return

	# 2. Movimentação em direção ao alvo
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	rotation = dir.angle()

	# 3. Lógica de Interceptação
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		# Se colidir com QUALQUER inimigo (seja o alvo ou alguém na frente)
		if is_instance_valid(body) and body.is_in_group("enemy"):
			if not hit_confirmado:
				_aplicar_dano_e_sumir(body)
			break # Para o loop de colisões

func _aplicar_dano_e_sumir(inimigo_atingido):
	hit_confirmado = true
	
	if inimigo_atingido.has_method("take_damage"):
		inimigo_atingido.take_damage(damage)
		print("🪓 Machado interceptado por: ", inimigo_atingido.name)
	
	# Desliga o processamento e remove o machado
	set_physics_process(false)
	queue_free()