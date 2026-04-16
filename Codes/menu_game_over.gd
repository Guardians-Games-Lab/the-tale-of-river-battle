extends CanvasLayer

# =========================
# 🎮 REFERÊNCIAS
# =========================
@onready var label_pontuacao = $MenuGameOver/MarginContainer/TextoGameOver
@onready var btn_new_game = $MenuGameOver/MarginContainer/Itens/NewGame
@onready var btn_menu = $MenuGameOver/MarginContainer/Itens/Sair

# =========================
# ⚙️ INICIALIZAÇÃO
# =========================
func _ready():
	# Puxa a pontuação final direto do nosso Autoload Game.gd
	label_pontuacao.text = "Pontuação: " + str(Game.Score)
	
	# Conecta os botões
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)


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