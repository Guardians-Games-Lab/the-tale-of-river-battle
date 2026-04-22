extends Node

func _ready():
    SilentWolf.configure({
        "api_key": "SEU_API_KEY_AQUI",
        "game_id": "SEU_GAME_ID_AQUI",
        "game_version": "1.0",          # mude quando atualizar o jogo
        "log_level": 1
    })
    
    SilentWolf.configure_scores({
        "open_scene_on_close": ""  # deixe vazio ou coloque a cena que quiser
    })
    
    # Login anônimo automático
    if not SilentWolf.Auth.is_logged_in():
        await SilentWolf.Auth.login_anonymous()
        print("Login anônimo feito! UID: ", SilentWolf.Auth.get_uid())

func enviar_pontuacao(score: int, player_name: String = "Jogador"):
    # player_name pode ser algo como "Cazenett" ou gerado automaticamente
    var result = await SilentWolf.Scores.persist_score(player_name, score, "main_leaderboard")
    
    if result.success:
        print("Pontuação enviada com sucesso!")
    else:
        print("Erro ao enviar: ", result.error)

func carregar_leaderboard():
    var result = await SilentWolf.Scores.get_high_scores(10, "main_leaderboard")
    
    if result.success:
        var scores = result.scores  # Array de dicionários
        for entry in scores:
            print(entry.player_name, " - ", entry.score)
            # Aqui você popula seu VBoxContainer, ItemList ou whatever UI você usa
    else:
        print("Erro ao carregar leaderboard")        