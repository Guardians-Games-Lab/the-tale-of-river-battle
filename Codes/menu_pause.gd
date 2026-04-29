extends CanvasLayer

# =========================
# 📂 REFERÊNCIAS DE UI
# =========================
@onready var texto_recorde = get_node_or_null("MenuPause/MarginContainer/PontuacaoMaxima/TextoPontuacaoMaxima")

# =========================
# 🚀 INICIALIZAÇÃO
# =========================
func _ready():
	hide()
	# Garante que este menu processe mesmo quando o resto do jogo parar
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		_toggle_pause()

# =========================
# ⏸️ LÓGICA DE PAUSA
# =========================
func _toggle_pause():
	var novo_estado = !get_tree().paused
	get_tree().paused = novo_estado
	visible = novo_estado
	
	if novo_estado:
		print("⏸️ Jogo Pausado")
		_atualizar_texto_recorde()
	else:
		print("▶️ Jogo Retomado")

# =========================
# 🏆 ATUALIZAR RECORDE (MULTIMAPAS)
# =========================
func _atualizar_texto_recorde():
	if not texto_recorde:
		return

	# Lemos o dicionário usando o mapa atual (ex: "mapa_1")
	var mapa_atual = Game.current_map
	var recorde_desse_mapa = Game.Highscores[mapa_atual]
	
	if recorde_desse_mapa > 0:
		texto_recorde.text = "🏆 Recorde (" + mapa_atual.replace("_", " ") + "): " + str(recorde_desse_mapa)
	else:
		texto_recorde.text = "🏆 Sem recorde no " + mapa_atual.replace("_", " ")

# =========================
# 🖱️ CONEXÕES DOS BOTÕES
# =========================
func _on_btn_continuar_pressed():
	# Retoma o jogo
	_toggle_pause()

func _on_btn_sair_pressed():
	# 1. Tira o jogo do pause imediatamente
	get_tree().paused = false 
	
	# 2. Muda de cena de forma segura e atrasada
	get_tree().call_deferred("change_scene_to_file", "res://main_menu.tscn")