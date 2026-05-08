extends Node2D
#O @onready ta sendo usado pra carregar a funcao _reaady antes de declarar a variavel
#Sem isso a declaracao ocorreria sem os child nodes respectivos gerando um codigo potencialmente defeituoso.
@onready var player: Area2D=$Player
@onready var enemy_manager: Node2D=$EnemyManager
@onready var ui: CanvasLayer=$UI
@onready var bg: Node2D=$Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.score_changed.connect(ui.update_score)
	GameManager.lives_changed.connect(ui.update_lives)
	GameManager.game_over.connect(_on_game_over)
	GameManager.reset()
	
	ui.update_score(GameManager.get_score())
	ui.update_lives(GameManager.get_lives())
	
func _on_game_over()->void:
	
	#Funcao que e chamada quando o Game Manager emite o sinal do game over
	enemy_manager.stop_spawning() #Inimigos param de spawnar
	ui.show_game_over() #Tela de game over e mostrada
	
	#A funcao abaixo esta chamando o objeto "SceneTree"
	#Objeto principal usado pela engine pra manejar o projeto
	#o comando abaixo faz com que todos os itens _process(
	#e _physics_process() parem
	get_tree().paused=true
	pass # Replace with function body.
