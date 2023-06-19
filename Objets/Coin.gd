extends Area2D

@onready var animPlayer: AnimationPlayer = get_node("AnimationPlayer")

signal HealReceived(amount)

func _on_body_entered(body):
	animPlayer.play("FadeOut")
