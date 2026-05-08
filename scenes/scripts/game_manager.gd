#Isso e uma singleton, basicamente um codigo que serve de gerente
#Ele nao esta dentro do projeto visualmente(nao tem node), porem ele e usado pelo projeto 
#Por paramentro de seguranca e eficiencia, assim os nodes nao precisam ficar se alterando, ou se chamando.
#Acredito que o node que mais vai usar do Game Manager e o "UI"
extends Node
#Signals that the UI node uses.
#It's useful because it lets the UI node react to the state changes without the GameManager
#Explicitly knowing anything about the UI node.
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over

#Constants
const  STARTING_SCORE: int=0
const MAX_LIVES: int=6


#Variables
#To chamando as vidas e o score das constantes
#Vamos usar essa coisa aqui pra poder comecar de um ponto.
var score: int=STARTING_SCORE
var lives: int=MAX_LIVES

#Variavel booleana para quando o numero de vidas for menor que zero
var is_game_over:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset()->void:
	#Funcao que reseta todos os status pro default
	score=STARTING_SCORE
	lives=MAX_LIVES
	is_game_over=false

func add_score(points:int)->void:
	#Nome auto explicativo
	score+=points
	#emit_signal basicamente atira o sinal,emite ele.
	#toda funcao neste conectada seraa ativada
	emit_signal("score_changed",score)

func lose_life()->void:
	lives-=1
	emit_signal("lives_changed",lives)
	if lives<0:
		is_game_over=true
		emit_signal("game_over")

#Getter functions
#Boa pratica na programacao, a funcao aqui 
#acaba sendo nao deixar que scripts de fora modificarem os estados diretamente
#Ou as variaveis num geral
func get_score()->int:
	return score

func get_lives()->int:
	return lives
