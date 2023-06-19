extends Node2D

@export var gravity = 0
var vector = Vector2()

func ready():
	get_tree().get_node("Player").connect("FallingTreeEnabled", Callable(self, "fall"))

func fall():
	print("works")
