extends Control


func _on_start_pressed():
	$UIsound.play()
	get_tree().change_scene_to_file("res://scenes/mainScene.tscn")




func _on_quit_pressed():
	$UIsound.play()
	get_tree().quit()
