extends Node

# =========================
# 📂 CONFIGURAÇÃO DE SAVE
# =========================
const SAVE_PATH = "user://highscore.save"


# =========================
# 💰 SISTEMA DE GOLD
# =========================
var Gold: int = 20
signal gold_changed

func add_gold(amount: int):
	Gold += amount
	gold_changed.emit()

func spend_gold(amount: int) -> bool:
	if Gold >= amount:
		Gold -= amount
		gold_changed.emit()
		return true
	return false


# =========================
# 📈 SISTEMA DE PONTOS E RECORDE
# =========================
var Score: int = 0
var Highscore: int = 0 # 🏆 Nossa nova variável para a pontuação máxima

signal score_changed

func add_score(amount: int):
	Score += amount
	score_changed.emit()
	
	# Checa se bateu o recorde atual
	if Score > Highscore:
		Highscore = Score
		print("🏆 NOVO RECORDE: ", Highscore)
		save_highscore() # 💾 Salva automaticamente sempre que bater o recorde


# =========================
# 💔 SISTEMA DE VIDA
# =========================
var Health: int = 100
signal health_changed
signal game_over

func take_damage(amount: int):
	Health -= amount 
	print("💧 Dano recebido: ", amount, " | Vida atual da Lagoa: ", Health)
	
	if Health <= 0:
		Health = 0
		game_over.emit()
		print("💀 GAME OVER! A lagoa foi totalmente poluída.")
	

	health_changed.emit()
	
	


# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	load_highscore() # 📂 Carrega o recorde assim que o jogo abre


# =========================
# 💾 SALVAR DADOS (SAVE)
# =========================
func save_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"highscore": Highscore
		}
		# Transforma o dicionário em texto JSON e salva
		file.store_line(JSON.stringify(data))
		print("💾 Highscore salvo com sucesso no dispositivo!")
	else:
		print("❌ ERRO ao tentar salvar o arquivo.")


# =========================
# 📂 CARREGAR DADOS (LOAD)
# =========================
func load_highscore():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_line()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var data = json.get_data()
			if data.has("highscore"):
				Highscore = data["highscore"]
				print("📂 Highscore carregado com sucesso: ", Highscore)
	else:
		print("⚠️ Nenhum save encontrado. Criando um novo perfil de jogador.")
		
		
# =========================
# 🌊 SISTEMA DE WAVES
# =========================
var Wave: int = 1
signal wave_changed

func set_wave(nova_wave: int):
	Wave = nova_wave
	wave_changed.emit()


	
func reset_stats():
	Health = 100        # Coloque aqui a vida inicial do jogador
	Gold = 20     # O dinheiro inicial para comprar a primeira torre
	Score = 0      # Pontuação zerada
	Wave = 1       # Volta para a onda 1
	health_changed.emit()
	gold_changed.emit()
	score_changed.emit()
	wave_changed.emit()
	# Se você usa sinais para atualizar a UI, pode emitir eles aqui também
	# hp_changed.emit(hp)
	# gold_changed.emit(gold)