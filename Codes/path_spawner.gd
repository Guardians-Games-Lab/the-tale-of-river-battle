extends Node2D

@export var enemy_types: Dictionary[String, PackedScene] = {}
@export var time_between_waves: float = 3.0
@export_file("*.json") var wave_file: String = "res://Data/waves_mapa1.json"

var waves: Array = []
var current_wave := 0
var enemies_alive := 0

# 👇 NOVA VARIÁVEL: A nossa "linha indiana" de inimigos
var spawn_queue: Array = [] 

@onready var path: Path2D = $Path2D
@onready var spawn_timer: Timer = $SpawnTimer


func _ready():
	# Blindagem: Garante que o timer não fique repetindo loucamente sozinho
	spawn_timer.one_shot = true 
	
	load_waves_from_json()
	if waves.size() > 0:
		start_wave()


# =========================
# 📂 CARREGAR WAVES DO JSON
# =========================
func load_waves_from_json():
	if FileAccess.file_exists(wave_file):
		var file = FileAccess.open(wave_file, FileAccess.READ)
		var content = file.get_as_text()
		var parsed_data = JSON.parse_string(content)
		
		if parsed_data != null and parsed_data is Array:
			waves = parsed_data
			print("🌊 Waves carregadas! Total de ondas: ", waves.size())
		else:
			print("❌ ERRO: O arquivo JSON está com o formato incorreto.")
	else:
		print("❌ ERRO: Arquivo JSON não encontrado.")


# =========================
# 🚀 COMEÇA WAVE (MONTAR A FILA)
# =========================
func start_wave():
	if current_wave >= waves.size():
		print("🏆 Você venceu! Fim das ondas!")
		return
		
	Game.set_wave(current_wave + 1)
	enemies_alive = 0
	spawn_queue.clear() # Limpa a fila da onda passada

	# 👇 O SEGREDO: Pega os grupos da onda atual e coloca todo mundo na mesma fila
	var grupos_da_wave = waves[current_wave]
	for grupo in grupos_da_wave:
		var qtd = grupo.get("quantity", 1)
		for i in range(qtd):
			spawn_queue.append({
				"type": grupo.get("type", "base"),
				"interval": grupo.get("interval", 1.0)
			})

	print("🚀 Wave ", current_wave + 1, " iniciada! Inimigos na fila: ", spawn_queue.size())

	# Se tiver gente na fila, manda o primeiro nascer imediatamente!
	if spawn_queue.size() > 0:
		_on_spawn_timer_timeout()


# =========================
# 👾 SPAWN INIMIGO (CHAMADO PELO TIMER)
# =========================
func _on_spawn_timer_timeout():
	if spawn_queue.is_empty():
		return # Fila vazia, não faz nada

	# 1. Tira o primeiro inimigo da fila
	var next_enemy_data = spawn_queue.pop_front()

	# 2. Cria o inimigo no mapa
	var type = next_enemy_data["type"]
	if enemy_types.has(type):
		var enemy_scene = enemy_types[type]
		var enemy = enemy_scene.instantiate()
		path.add_child(enemy)
		
		enemies_alive += 1

		var body = enemy.get_node("Enemy")
		body.died.connect(_on_enemy_removed)
		body.escaped.connect(_on_enemy_removed)
	else:
		print("❌ ERRO: Tipo '", type, "' não configurado no Inspetor do Spawner!")

	# 3. Se ainda sobrou gente na fila, liga o timer de novo!
	if not spawn_queue.is_empty():
		spawn_timer.wait_time = next_enemy_data["interval"]
		spawn_timer.start()


# =========================
# 💀 REMOÇÃO DE INIMIGO
# =========================
func _on_enemy_removed():
	if enemies_alive <= 0:
		return

	enemies_alive -= 1

	# A onda só acaba quando a fila esvaziar E todos os inimigos do mapa morrerem/fugirem
	if spawn_queue.is_empty() and enemies_alive == 0:
		next_wave()


# =========================
# 🔁 PRÓXIMA WAVE
# =========================
func next_wave():
	current_wave += 1

	if current_wave < waves.size():
		print("⏳ Próxima wave em ", time_between_waves, " segundos...")
		await get_tree().create_timer(time_between_waves).timeout
		start_wave()
	else:
		print("🎉 Fim de todas as ondas!")
