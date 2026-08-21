extends Control

# Arraste o nó do Timer para cá no Inspetor ou use o caminho direto
@onready var timer = $Timer

func _ready():
	# Inicia o cronômetro assim que a cena abre
	timer.start()
	
	# Conecta o sinal do fim do tempo à função de trocar de cena
	timer.timeout.connect(_ao_terminar_tempo)

func _ao_terminar_tempo():
	# Troca para o seu Menu Principal (ajuste o caminho para o seu arquivo .tscn)
	get_tree().change_scene_to_file("res://main_menu.tscn")