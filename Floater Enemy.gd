extends CharacterBody2D
class_name Enemy

@export var speed = 50
var motion = Vector2()

func _physics_process(delta):
	$Sprite2D.play("Idle")



func kill() -> void:
	queue_free()





func _on_Area2D_body_entered(body):
	pass # Replace with function body.
