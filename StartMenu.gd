#StartMenu.gd
extends Control

func _on_StartGame_pressed():
	get_tree().change_scene_to_file("res://Levels/Level 1/Level 1.tscn")


func _on_Quit_pressed():
	get_tree().quit()
