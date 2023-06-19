extends CharacterBody2D

@onready var invulnerabilityTimer = $"Invulnerability timer"
@onready var effectsAnimations = $AnimationPlayer
@onready var atterissageSound = $Atterissage
@onready var dashSound = $Dash
@onready var walkSound = $Marche
@onready var jumpSound = $Saut

@onready var health = 2

const UP = Vector2(0, -1) 						# cette valeur ne change jamais car la variable est constante
@export var GRAVITY: float = 20.0							# On utilise des variables pour remplacer les valeurs numériques dans les fonctions
@export var CHANGEGRAVITY: float = 0
@export var ACCELERATION: float = 200
const MAX_SPEED  = 500
@export var JUMP_HEIGHT = -600
@export var stompImpulse = 600

@export var dashForce = 20
@export var dashMove = 600
@export var maxDashCount = 10
@export var dashCount = 0

signal DamageTaken(amount)

var enableDash = false
var friction = false

signal FallingTreeEnabled

var collided = false
var collision: KinematicCollision2D

@export_file ("*.tscn") var world_scene: String

var motion = Vector2() 							#contient x et y dans une seule variable

var DestructibleWall: TileMap
var cell
var tile_id


#

func _ready():
	DestructibleWall = get_parent().get_node("Destructible Wall")
	invulnerabilityTimer.start()


#Use the function below to check things like if HealthBar.Value == 0, since it
#has to be checked constantly.

func _physics_process(delta):
	motion.x = 0
	apply_Gravity()
	
	
	if is_Running_Right():
		move_Right()
	
	if is_Running_Left():
		move_Left()
	
	if is_Jumping():
		move_Up()
		jumpSound.play()
		enableDash = true
	
	if is_In_The_Air():
		if motion.y < 0:
			play_Jump()
		if motion.y > 0:
			play_Fall()
	
	if is_No_Movement():
		play_Idle()
	
	if is_Running():
		play_Run()
	
	if can_Dash():
		dash()
		dashSound.play()
	
	if is_Dashing():
		dash()
	else:
		dashCount = 0
	
	reapply_Gravity()
	
	handle_Collision()
	
	
#	destroy_Wall()
	
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

#Anything HealthBar, Damage and Death related.

func restartLevel():
	get_tree().change_scene_to_file(world_scene)

func _on_GUI_restart():
	restartLevel()

func _on_electric_trap_body_entered(body):
	if invulnerabilityTimer.is_stopped():
		emit_signal("DamageTaken", 1)

func _on_damage_area_body_entered(body):
	if invulnerabilityTimer.is_stopped() and body.name == "Player" :
		emit_signal("DamageTaken", 1)

func _on_spiker_damage_body_entered(body):
	if invulnerabilityTimer.is_stopped() and body.name == "Player" :
		emit_signal("DamageTaken", 1)

func _on_DeathBarrier_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file(world_scene)

func _on_Invulnerability_timer_timeout():
	effectsAnimations.play("RESET")
	print("timeout")

#Movements, Physics applied to the player and Animations. 

func apply_Gravity():
	motion.y += GRAVITY

func enable_Friction():
	friction = true

func disable_Friction():
	friction = false

func is_Jumping():
	return Input.is_action_pressed("ui_up") and is_on_floor()

func is_Running_Right():
	return Input.is_action_pressed("ui_right")

func is_Running_Left():
	return Input.is_action_pressed("ui_left")

func move_Up():
	motion.y = JUMP_HEIGHT

func move_Right():
	motion.x = min(motion.x + ACCELERATION, MAX_SPEED)

func move_Left():
	motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)

func can_Dash():
	return !is_on_floor() and Input.is_action_pressed("ui_accept") and motion.x != 0 and enableDash == true

func is_Dashing():
	return dashCount > 0 and dashCount < maxDashCount 

func dash():
	dashCount += 1
	enableDash = false
	GRAVITY = 0
	motion.y = 0
	if motion.x > 0 and dashCount < maxDashCount:
		motion.x = motion.x + dashMove
	if motion.x < 0:
		motion.x = motion.x - dashMove

func reapply_Gravity():
	if !is_Dashing():
		GRAVITY = 20

func is_In_The_Air():
	return !is_on_floor()

func is_No_Movement():
	return motion.x == 0 and is_on_floor() == true 

func is_Running():
	return motion.x != 0 and is_on_floor() == true 

func play_Jump():
	$Sprite2D.play("Jump")

func play_Fall():
	$Sprite2D.play("Fall")

func play_Idle():
	$Sprite2D.play("Idle")

func play_Run():
	
	if motion.x < 0 and motion.x >= -200 :
		$Sprite2D.flip_h = true
	elif motion.x > 0 and motion.x <= 200:
		$Sprite2D.flip_h = false
	$Sprite2D.play("Run")

func play_Dash():
	if motion.x > -200:
		$Sprite2D.flip_h = true
	elif motion.x < 200:
		$Sprite2D.flip_h = false
	$Sprite2D.play("Dash")
	$Sprite2D.stop("Jump", "Fall")

func handle_Collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "Floater":
			kill_Enemy(collision, collider)
		if collider.name == "DestructibleWallV2":
			destroy_Wall(collision, collider)

#Kill and Destroy stuff.

func destroy_Wall(collision:KinematicCollision2D, collider):
	if dashCount > 0 and dashCount < maxDashCount:
		cell = DestructibleWall.local_to_map(collision.position - collision.normal)
		tile_id = DestructibleWall.get_cellv(cell)
		var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
		DestructibleWall.set_cellv(cell, -1)


func kill_Enemy(collision:KinematicCollision2D, collider):
	var is_stomping: bool = (
		collider is Enemy and
		is_on_floor() and
		collision.get_normal().dot(Vector2.UP) > 0.5
	)
	if is_stomping:
		motion.y = -stompImpulse
		(collider as Enemy).kill()
		dashCount = 0
		enableDash = true









#func _on_Detection_body_entered(body):
#	var fallingTree = get_parent().get_node("FallingTree").get_child(2)
#	if is_Dashing() and body == fallingTree:
#		print("lol")
#	if is_Dashing() and body.name == "FallingTree" :
#		print("lol")
#		emit_signal("FallingTreeEnabled")















