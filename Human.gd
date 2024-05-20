extends CharacterBody2D

@export var rotation_speed = 5.0 # Speed of rotation


func _process(delta):
	# Apply friction to gradually stop the character
	velocity = velocity.move_toward(Vector2(), 300 * delta)
	move_and_slide()
	
	# Smoothly rotate the character towards the direction of the velocity if moving
	if velocity.length() > 0.1:
		var target_angle = velocity.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func apply_recoil(force):
	velocity += force
