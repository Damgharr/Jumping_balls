extends CanvasLayer

signal restart
@onready var HealthBar = $MarginContainer/VBoxContainer/HealthBar


func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	restartGame()


func _on_player_damage_taken(amount):
	HealthBar.value -= amount
	print("Player has :", HealthBar.value)

func restartGame():
	if HealthBar.value == 0:
		emit_signal("restart")


