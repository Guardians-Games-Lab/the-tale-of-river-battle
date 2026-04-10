extends CharacterBody2D

@export var speed: float = 250.0

var target = null
var damage: int = 10
# 👇 TRAVA DE SEGURANÇA
var hit_confirmado := false


func _physics_process(delta):
	if target == null or not is_instance_valid(target):
		queue_free()
		return

	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	rotation = dir.angle()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		# 👇 2. SÓ ATACA SE AINDA NÃO TIVER BATIDO
		if body == target and not hit_confirmado:
			hit_confirmado = true # Trava o machado pra não dar dano duplo!
			
			if body.has_method("take_damage"):
				body.take_damage(damage)
				
			queue_free()
			break # 👇 3. PARA O LOOP IMEDIATAMENTE

		if body == target:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
