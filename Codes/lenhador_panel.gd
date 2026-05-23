extends Panel

@export var tower_scene: PackedScene
@export var tower_cost: int = 20

func _on_gui_input(event):
	var pressionado: bool = false
	
	# Detecta o toque na tela do celular ou clique do mouse
	if event is InputEventScreenTouch and event.pressed:
		pressionado = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressionado = true

	if pressionado:
		# 🛑 O SEGREDO DO PAINEL: Mata o clique aqui para ele não "vazar" pro mapa!
		accept_event() 
		
		var game = get_tree().get_first_node_in_group("game")
		if game:
			game.start_build_mode(tower_scene, tower_cost)
	
