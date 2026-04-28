extends Control

@onready var score_container = $M/VBoxContainer/ScrollContainer/VBoxContainer
var score_item_scene = preload("res://Scenes/Menu/score_item.tscn") #⚠️ COLOCA O CAMINHO CORRETO AQUI

func _ready():
	# Fica à escuta do sinal do Game.gd para saber quando a tabela atualizou
	Game.leaderboard_atualizado.connect(atualizar_tela)
	
	# Atualiza a interface mal o ecrã seja aberto
	atualizar_tela()

func atualizar_tela():
	# Limpa as linhas antigas
	for child in score_container.get_children():
		child.queue_free()

	# Pega os dados diretamente da variável local do Autoload
	var scores = Game.lan_scores
	
	if scores.is_empty():
		var error_label = Label.new()
		error_label.text = "Ainda não há recordes no Servidor."
		score_container.add_child(error_label)
		return

	# Desenha as linhas com os resultados
	for i in range(scores.size()):
		var score_data = scores[i]
		var item = score_item_scene.instantiate()
		score_container.add_child(item)
		
		# Acede aos dados do Dicionário (player_name e score)
		item.configurar_linha(i + 1, str(score_data.player_name), score_data.score)
