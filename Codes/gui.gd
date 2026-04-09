extends CanvasLayer


@onready var moneyLabel = $Gui/TextoDinheiro/DinheiroTotal
@onready var pointsLabel = $Gui/TextoPontos/PontosTotal
@onready var lifeLabel = $VidaProgressBar/TextoVida
@onready var healthBar = $VidaProgressBar

func _ready():
	Game.gold_changed.connect(update_ui)
	Game.score_changed.connect(update_ui)
	Game.health_changed.connect(update_ui)
	update_ui()


func update_ui():
	moneyLabel.text = "$" + str(Game.Gold)
	pointsLabel.text = str(Game.Score)
	lifeLabel.text = "Life: " + str(Game.Health)
	# 📈 2. Atualiza o valor da barrinha
	healthBar.value = Game.Health
