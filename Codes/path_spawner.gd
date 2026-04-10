extends Node2D

# Dicionário tipado: obriga o Godot a aceitar apenas Cenas (PackedScene)
@export var enemy_types: Dictionary[String, PackedScene] = {}
@export var time_between_waves: float = 3.0

# Define onde o arquivo JSON está guardado
@export_file("*.json") var wave_file: String = "res://Data/waves_mapa1.json"

var waves: Array = []
var current_wave := 0
var enemies_spawned := 0
var enemies_alive := 0

@onready var path: Path2D = $Path2D
@onready var spawn_timer: Timer = $SpawnTimer


func _ready():
	load_waves_from_json() # ⬅️ Carrega o arquivo antes de começar o jogo!
	
	if waves.size() > 0:
		start_wave()


# =========================
# 📂 CARREGAR WAVES DO JSON
# =========================
func load_waves_from_json():
	if FileAccess.file_exists(wave_file):
		# Abre o arquivo em modo de leitura
		var file = FileAccess.open(wave_file, FileAccess.READ)
		var content = file.get_as_text() # Pega todo o texto
		
		# Transforma o texto JSON em um Array nativo do Godot
		var parsed_data = JSON.parse_string(content)
		
		if parsed_data != null and parsed_data is Array:
			waves = parsed_data
			print("🌊 Waves carregadas com sucesso! Total de ondas: ", waves.size())
		else:
			print("❌ ERRO: O arquivo JSON está com o formato incorreto.")
	else:
		print("❌ ERRO: Arquivo JSON não encontrado em: ", wave_file)


# =========================
# 🚀 COMEÇA WAVE
# =========================
func start_wave():
	if current_wave >= waves.size():
		print("Fim das ondas!")
		return
		
	# AVISA O GAME.GD QUAL É A ONDA ATUAL (soma 1 para a UI não mostrar "Wave 0")
	Game.set_wave(current_wave + 1)
	
	enemies_spawned = 0
	enemies_alive = 0

	spawn_timer.wait_time = waves[current_wave]["interval"]
	spawn_timer.start()


# =========================
# 👾 SPAWN INIMIGO (MÚLTIPLOS TIPOS)
# =========================
func _on_spawn_timer_timeout():
	# 1. Pega os dados da wave atual e descobre o tipo
	var wave_data = waves[current_wave]
	var type = wave_data.get("type", "base") # "base" é o padrão se o JSON não tiver "type"

	# 2. Verifica se o tipo existe no dicionário e cria o inimigo
	if enemy_types.has(type):
		var enemy_scene = enemy_types[type]
		var enemy = enemy_scene.instantiate()
		path.add_child(enemy)
		
		enemies_spawned += 1
		enemies_alive += 1

		var body = enemy.get_node("Enemy")

		# Conecta os sinais de morte e fuga
		body.died.connect(_on_enemy_removed)
		body.escaped.connect(_on_enemy_removed)
	else:
		print("❌ ERRO: Tipo de inimigo '", type, "' não foi adicionado no Inspetor do Spawner!")

	# 3. Para o timer se já nasceram todos
	if enemies_spawned >= wave_data["quantity"]:
		spawn_timer.stop()


# =========================
# 💀 REMOÇÃO DE INIMIGO
# =========================
func _on_enemy_removed():
	if enemies_alive <= 0:
		return

	enemies_alive -= 1
	print("Inimigos vivos:", enemies_alive)

	if enemies_alive == 0 and enemies_spawned >= waves[current_wave]["quantity"]:
		next_wave()


# =========================
# 🔁 PRÓXIMA WAVE
# =========================
func next_wave():
	current_wave += 1

	if current_wave < waves.size():
		print("Próxima wave:", current_wave)
		await get_tree().create_timer(time_between_waves).timeout
		start_wave()
	else:
		print("Fim das ondas!")
