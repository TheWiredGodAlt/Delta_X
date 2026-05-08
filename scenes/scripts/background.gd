extends Node2D

#@export deixa essa variavel visivel e exposta pra que vc possa editar ela 
#sem ter de mexer no codigo
@export var scroll_speed: float=200.0
#Declara essas variaveis antes do codigo ser carregado
@onready var bg_1:Sprite2D=$bg1
@onready var bg_2:Sprite2D=$bg2

var texture_height:float=0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Basicamente um calculo para que toda vez que a funcao for chamada
	#A segunda imagem seja colocada exatamente acima dela
	if bg_1.texture !=null:
		texture_height=float (bg_1.texture.get_height())
	bg_2.position.y=bg_1.position.y-texture_height

# Called every frame. 'delta' is the elapsed time since the previous frame.
#valor de delta= segundos passados desde o ultimo frame
func _process(delta: float) -> void:
	#executa essa funcao durante toda a execucao do codigo
	_scroll(delta)

func _scroll(delta:float)->void:
	#Logica para que os sprites descam
	bg_1.position.y+=scroll_speed*delta
	bg_2.position.y+=scroll_speed*delta
	
	# Logica para pegar o tamanho da tela
	var screen_h:float=get_viewport().get_visible_rect().size.y
	#Logica que teleporta cada uma das duas imagens para o topo quando
	#ela chega ao final, no caso se divide por 0.5 para que a imagem sempre se repita antes de acabar 
	#propriamente
	if bg_1.position.y>=screen_h+texture_height*0.5:
		bg_1.position.y=bg_2.position.y-texture_height
	#logica da imagem 2
	if bg_2.position.y>=screen_h+texture_height*0.5:
		bg_2.position.y=bg_1.position.y-texture_height
