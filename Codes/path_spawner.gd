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

@onready var path: Path2D = $Path2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

func _ready():
	start_wave()

func start_wave():
	enemies_spawned = 0
	spawn_timer.wait_time = waves[current_wave]["interval"]
	spawn_timer.start()

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	path.add_child(enemy)
	enemies_spawned += 1

	if enemies_spawned >= waves[current_wave]["quantity"]:
		spawn_timer.stop()
		wave_timer.start()

func _on_wave_timer_timeout():
	current_wave += 1
	if current_wave < waves.size():
		start_wave()
	else:
		print("Fim das ondas!")
