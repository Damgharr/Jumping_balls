extends Path2D

@export var speed = 100
@onready var follow = get_node("SpikerFollow")

func _process(delta):
	#(follow.get_offset() + speed * delta)
	follow.progress += speed * delta
