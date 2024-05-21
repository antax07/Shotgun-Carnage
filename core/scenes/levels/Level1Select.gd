extends Area2D



func _on_area_entered(area):
	print("area enterd")
	get_tree().change_scene_to_file("res://core/scenes/environment/test_obstacle.tscn")
