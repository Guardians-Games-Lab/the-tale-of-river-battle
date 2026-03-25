extends Node2D

@export var enemy_scene: PackedScene
@export var time_between_waves: float = 3.0
@export var waves: Array[Dictionary] = [
	{"quantity": 3, "interval": 1.5},
	{"quantity": 5, "interval": 1.0},
	{"quantity": 8, "interval": 0.7},
]

var current_wave := 0
var enemies_spawned := 0
var enemies_alive := 0

@onready var path: Path2D = $Path2D
@onready var spawn_timer: Timer = $SpawnTimer


func _ready():
	start_wave()


func start_wave():
	if current_wave >= waves.size():
		print("Fim das ondas!")
		return

	enemies_spawned = 0
	enemies_alive = 0

	spawn_timer.wait_time = waves[current_wave]["interval"]
	spawn_timer.start()


func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	path.add_child(enemy)

	enemies_spawned += 1
	enemies_alive += 1

	var body = enemy.get_node("Enemy")
	
	body.connect("died", _on_enemy_removed)
	body.connect("escaped", _on_enemy_removed)

	if enemies_spawned >= waves[current_wave]["quantity"]:
		spawn_timer.stop()

#Chega no Final
func _on_enemy_removed():
	enemies_alive -= 1
	print("Inimigos vivos:", enemies_alive)

	# só vai para a próxima wave se todos os inimigos foram spawnados E não houver mais vivos
	if enemies_alive == 0 and enemies_spawned >= waves[current_wave]["quantity"]:
		next_wave()


#Inimigos mortos

func next_wave():
	current_wave += 1

	if current_wave < waves.size():
		print("Próxima wave:", current_wave)
		await get_tree().create_timer(time_between_waves).timeout
		start_wave()
	else:
		print("Fim das ondas!")
