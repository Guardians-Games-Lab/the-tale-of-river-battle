extends Panel


@onready var moneyLabel = $TextoDinheiro/DinheiroTotal
@onready var pointsLabel = $TextoPontos/PontosTotal

func _ready():
	Game.gold_changed.connect(update_ui)
	Game.score_changed.connect(update_ui)
	update_ui()


func update_ui():
	moneyLabel.text = "$" + str(Game.Gold)
	pointsLabel.text = str(Game.Score)
