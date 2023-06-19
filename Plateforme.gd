extends Path2D

@export var speed = 100
@onready var follow = get_node("Circuit")

func _process(delta):
	follow.set_offset(follow.get_offset() + speed * delta)
