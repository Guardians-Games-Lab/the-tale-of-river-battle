extends Control

@onready var score_container = $VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
    # Vamos buscar os scores assim que a tela abrir
    load_scores()

func load_scores():
    # Limpa a lista antes de carregar (previne duplicatas)
    for child in score_container.get_children():
        child.queue_free()

    # Chama o SilentWolf para pegar o Top 10
    var sw_result = await SilentWolf.Scores.get_scores(10).sw_get_scores_complete
    setup_leaderboard(sw_result.scores)

func setup_leaderboard(scores):
    if scores.is_empty():
        var error_label = Label.new()
        error_label.text = "Ninguém jogou ainda. Que triste."
        score_container.add_child(error_label)
        return

    for i in range(scores.size()):
        var score_data = scores[i]
        var hbox = HBoxContainer.new()
        
        # Rank, Nome e Pontuação
        var rank_label = Label.new()
        rank_label.text = str(i + 1) + ". "
        rank_label.custom_minimum_size.x = 30
        
        var name_label = Label.new()
        name_label.text = str(score_data.player_name)
        name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
        var points_label = Label.new()
        points_label.text = str(score_data.score)
        
        hbox.add_child(rank_label)
        hbox.add_child(name_label)
        hbox.add_child(points_label)
        
        score_container.add_child(hbox)

