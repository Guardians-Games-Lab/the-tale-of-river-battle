extends Panel

@export var tower_scene: PackedScene

func _gui_input(event):
    # Detecta o toque do dedo na tela (ou clique) no exato momento em que pressiona
    if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
        var game = get_tree().get_first_node_in_group("game")
        
        if game:
            game.start_build_mode(tower_scene)