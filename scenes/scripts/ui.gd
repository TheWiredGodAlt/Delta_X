
extends CanvasLayer


@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/FinalScoreLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton


func _ready() -> void:
	# Hide game over screen at the start.
	game_over_panel.visible = false

	# Connect restart button.
	# .pressed is a signal emitted when a Button is clicked.
	restart_button.pressed.connect(_on_restart_pressed)


func update_score(new_score: int) -> void:
	# Format string using the % operator.
	# %d = integer placeholder. Works like printf("%d", n) in C.
	score_label.text = "SCORE: %d" % new_score


func update_lives(new_lives: int) -> void:
	lives_label.text = "LIVES: %d" % new_lives


func show_game_over() -> void:
	final_score_label.text = "FINAL SCORE: %d" % GameManager.get_score()
	game_over_panel.visible = true


func _on_restart_pressed() -> void:
	# Unpause the game (Main.gd paused it on game_over).
	get_tree().paused = false
	# Reload the current scene from scratch — full reset.
	# This is equivalent to restarting the program.
	get_tree().reload_current_scene()
