extends Area2D





func _on_body_entered(body):
	print("area enterd")
	if body.name == 'Player':
		get_tree().change_scene_to_file("res://core/scenes/levels/test_level.tscn")
