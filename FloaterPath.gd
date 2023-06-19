extends Path2D

var Direction = "Left"
@export var speed = 100
@onready var follow = get_node("Follow")

func _process(delta):
	#(follow.get_offset() + speed * delta)
	follow.progress += speed * delta

	

	
	
