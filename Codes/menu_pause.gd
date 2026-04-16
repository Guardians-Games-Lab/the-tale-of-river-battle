extends CanvasLayer


@onready var texto_recorde = $MenuPause/MarginContainer/PontuacaoMaxima/TextoPontuacaoMaxima


# =========================
# ⏸️ LÓGICA DE PAUSA
# =========================

func _ready():
	# Começa escondido
	hide()
	# Garante que os botões funcionem mesmo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Atalho no teclado (Esc ou P)
	if event.is_action_pressed("ui_cancel"): 
		_toggle_pause()

func _toggle_pause():
	var novo_estado = !get_tree().paused
	get_tree().paused = novo_estado
	visible = novo_estado
	
	if novo_estado:
		print("⏸️ Jogo Pausado")
		_atualizar_texto_recorde() # 👇 Chama a função de ler o recorde sempre que abrir o menu!
	else:
		print("▶️ Jogo Retomado")


# =========================
# 🏆 ATUALIZAR RECORDE NA TELA
# =========================
func _atualizar_texto_recorde():
	# Verifica se a variável Highscore lá do seu Game.gd é maior que zero
	if Game.Highscore > 0:
		texto_recorde.text = "🏆 Maior Pontuação: " + str(Game.Highscore)
	else:
		# Se for 0, mostra a frase padrão
		texto_recorde.text = "🏆 Nenhum recorde ainda!"
		
# =========================
# 🖱️ CONEXÕES DOS BOTÕES
# =========================

func _on_btn_continuar_pressed():
	_toggle_pause()

func _on_btn_sair_pressed():
	get_tree().paused = false # Importante: despausar antes de sair!
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Se você tem um botão de Pause na sua GUI principal, 
# ele deve chamar a função _toggle_pause() deste script.