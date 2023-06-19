#WorldComplete.gd
extends Area2D

@export_file ("*.tscn") var world_scene: String

func _physics_process(delta):
	var bodies = get_overlapping_bodies() 	# bodies détecte si des objets se touche
	for body in bodies:						# On fait en sorte qu'un objet spécifique touche la cible 
		if body.name == "Player":			# Ici, on dit que le body est nommé Player
			get_tree().change_scene_to_file(world_scene)			# Et lorsque qu'un objet nommé Player touche la cible,
															# On a accès au prochain niveau
