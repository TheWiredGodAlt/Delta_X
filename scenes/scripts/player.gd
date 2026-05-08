extends Area2D
#Estamos usando Area2d por que o player nao tem
#colisao ativa propriamente. Logo sua colisao nao muda nada nos objetos do jogo
@export var speed:int=300
@export var bullet_scene:PackedScene
@export var shot_rate:float=0.15

#Carregando antes de iniciar a execucao do codigo completo
@onready var sprite:AnimatedSprite2D=$AnimatedSprite2D
@onready var collision:CollisionShape2D=$CollisionShape2D
@onready var gun:Marker2D=$GunPoint
@onready var fire_timer:Timer=$FireTimer

#Estados default
var can_shot:bool=true
var is_dead:bool=false
#Declara uma variavel que tem os valores de vector 2
#Logo tudo que se faz nela tem efeito nos vetores
var screen_size:Vector2

func _ready() -> void:
	#Adiciona esse node ao grupo player (oque quer que isso signifique
	add_to_group("player")
	#Oque caralhos essa porra aqui faz????
	screen_size=get_viewport().get_visible_rect().size
	#Configuracao da logica do firetimer
	fire_timer.wait_time=shot_rate
	fire_timer.one_shot=false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	area_entered.connect(_on_area_entered)
	sprite.play("idle")

func _process(delta: float) -> void:
	if is_dead:
		return
	_movement(delta)
	_shooting()
#codigo de movimento do player
func _movement(delta:float)->void:
	var direction:Vector2=Vector2.ZERO
	if Input.is_action_pressed("left"):
		direction.x-=1.0
	if Input.is_action_pressed("right"):
		direction.x+=1.0
	if Input.is_action_pressed("up"):
		direction.y-=1.0
	if Input.is_action_pressed("down"):
		direction.y+=1.0
	if direction.length()>0.0:
		direction=direction.normalized()
	position+=direction*speed*delta
	#a funcao clamp previne o player de sair da tela (sem que tenhamos que usar colisao)
	position.x=clamp(position.x,0.0,screen_size.x)
	position.y=clamp(position.y,0.0,screen_size.y)
	if direction.x<0.0:
		sprite.play("left")
	elif direction.x >0.0:
		sprite.play("right")
	else:
		sprite.play("idle")

func _shooting()->void:
	if Input.is_action_just_pressed("shoot") and can_shot:
		_fire()
		can_shot=false
		fire_timer.start()

func _fire()->void:
	if bullet_scene==null:
		#Por que essa buceta maldita cabeluda de merda ta aqui???
		push_warning("You don't have a bullet scene")
		return
		#nao entendi porra nenhuma do que ta aqui, olha essa merda dps
	var bullet:Node2D=bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	#De novo, mais uma que nao tenho ideia do que ta fazendo nessa merda olha isso
	bullet.global_position=gun.global_position

#Timer do tiro do player
func _on_fire_timer_timeout() -> void:
	can_shot=true 

func _on_area_entered(area:Area2D)->void:
	if area.is_in_group("enemy_bullets") or area.is_in_group("enemies"):
		take_damage()

func take_damage()->void:
	if is_dead:
		return
	is_dead=true
	collision.set_deferred("disabled",true)
	sprite.play("death")
	GameManager.lose_life()
	await get_tree().create_timer(1.5).timeout
	
	if not GameManager.is_game_over:
		_respawn()
	else:
		queue_free()
func _respawn()->void:
	is_dead=false
	position=Vector2(screen_size.x*0.5,screen_size.y-100.0)
	
	collision.set_deferred("disabled",false)
	sprite.play("idle")
	
