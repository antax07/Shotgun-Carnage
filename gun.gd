extends Node2D

@export var max_aim_angle = 30 # Maximum allowed angle in degrees
var chair_direction = Vector2.RIGHT # This represents the initial direction the player is facing

func _ready():
	chair_direction = global_position.direction_to(get_parent().global_position).rotated(get_parent().rotation)

func _process(delta):
	var aim_direction = (get_global_mouse_position() - global_position).normalized()
	
	# Calculate the angle between the chair direction and the aim direction
	var angle = chair_direction.angle_to(aim_direction)
	
	# Convert angle constraint from degrees to radians
	var max_angle_rads = deg_to_rad(max_aim_angle / 2.0) # Half the angle to get ± max angle
	
	# Constrain the aim direction within the allowed angle range
	if angle < -max_angle_rads:
		aim_direction = chair_direction.rotated(-max_angle_rads)
	elif angle > max_angle_rads:
		aim_direction = chair_direction.rotated(max_angle_rads)
	
	# Apply the rotation to the gun
	rotation = aim_direction.angle()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_just_pressed("shoot"):
			var aim_direction = (get_global_mouse_position() - global_position).normalized()
			
			# Calculate the angle between the chair direction and the aim direction
			var angle = chair_direction.angle_to(aim_direction)
			
			# Convert angle constraint from degrees to radians
			var max_angle_rads = deg_to_rad(max_aim_angle / 2.0) # Half the angle to get ± max angle
			
			# Constrain the aim direction within the allowed angle range
			if angle < -max_angle_rads:
				aim_direction = chair_direction.rotated(-max_angle_rads)
			elif angle > max_angle_rads:
				aim_direction = chair_direction.rotated(max_angle_rads)
			
			# Calculate the recoil force based on the constrained aim direction
			var recoil_force = -aim_direction * 200
			
			# Apply recoil to the player
			get_parent().apply_recoil(recoil_force)
