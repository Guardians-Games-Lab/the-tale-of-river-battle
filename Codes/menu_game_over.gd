extends CanvasLayer

# =========================
# 🎮 REFERÊNCIAS
# =========================
@onready var label_pontuacao = $MenuGameOver/MarginContainer/Pontuacao/TextoPontuacao
@onready var btn_new_game = $MenuGameOver/MarginContainer/Itens/NewGame
@onready var btn_menu = $MenuGameOver/MarginContainer/Itens/Sair

# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	# Puxa a pontuação final direto do nosso Autoload Game.gd
	
	
	# Conecta os botões
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)

	# 2. 👂 O PULO DO GATO: A tela escuta quando o jogo acabar!
	Game.game_over.connect(_atualizar_textos_finais)

# =========================
# 🔄 BOTÃO: NEW GAME
# =========================
func _on_new_game_pressed():
	# 1. Esconde a tela imediatamente
	self.visible = false
	
	# 2. Despausa a árvore PRIMEIRO
	get_tree().paused = false 
	
	# 3. Zera os status
	Game.reset_stats() 
	
	# 4. 🔁 COMANDO NATIVO: Recarrega a fase atual automaticamente!
	get_tree().call_deferred("reload_current_scene")


# =========================
# 🚪 BOTÃO: SAIR PARA O MENU
# =========================
func _on_menu_pressed():
	# 1. Despausa a árvore PRIMEIRO
	get_tree().paused = false 
	
	# 2. 🚪 COMANDO NATIVO: Vai direto para o Menu
	get_tree().call_deferred("change_scene_to_file", "res://main_menu.tscn")

# =========================
# 📝 ATUALIZAR DADOS
# =========================
func _atualizar_textos_finais():
	# Essa função só vai rodar na hora que a lagoa morrer!
	label_pontuacao.text = "Pontuação: " + str(Game.Score)