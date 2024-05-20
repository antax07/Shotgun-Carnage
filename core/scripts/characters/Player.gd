extends RigidBody2D

@export var aiming_cone_angle = 80.0
@export var recoil = 100.0
@export var rotation_force = 0.15
@export var reload_time = 1.6
@export var linear_friction = 25.0
@export var angular_friction = 1.0
@export var tip_toe_interval = 1.0
@export var tip_toe_impulse = 1.5

@onready var chair_sprite = $ChairSprite
@onready var player_sprite = $ChairSprite/PlayerSprite
@onready var animation_player = $AnimationPlayer

var can_shoot = true
var aiming_direction = 0.0
var can_tip_toe = true
var shots_fired = 0

func _ready():
	animation_player.play("idle")

func _process(delta):
	handle_aiming(delta)
	handle_rotation(delta)
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

func handle_aiming(delta):
	var chair_rotation = chair_sprite.global_rotation_degrees
	var absolute_player_to_cursor = rad_to_deg(player_sprite.global_position.angle_to_point(get_global_mouse_position()))
	
	chair_rotation = normalize_angle_180(chair_rotation)
	absolute_player_to_cursor = normalize_angle_180(absolute_player_to_cursor)
	
	aiming_direction = absolute_player_to_cursor - chair_rotation
	aiming_direction = normalize_angle_180(aiming_direction)

	if aiming_direction > aiming_cone_angle / 2:
		aiming_direction = aiming_cone_angle / 2
	elif aiming_direction < -aiming_cone_angle / 2:
		aiming_direction = -aiming_cone_angle / 2
	
	player_sprite.rotation_degrees = aiming_direction

func handle_rotation(delta):
	if Input.is_action_pressed("rotate_clockwise") and can_tip_toe:
		apply_tip_toe_impulse(tip_toe_impulse)
	elif Input.is_action_pressed("rotate_counterclockwise") and can_tip_toe:
		apply_tip_toe_impulse(-tip_toe_impulse)

func apply_tip_toe_impulse(impulse):
	angular_velocity += impulse
	can_tip_toe = false
	await get_tree().create_timer(tip_toe_interval).timeout
	can_tip_toe = true

func normalize_angle_180(angle):
	angle = fmod(angle, 360.0)
	if angle > 180:
		angle -= 360.0
	elif angle < -180:
		angle += 360.0
	return angle

func _integrate_forces(state):
	if linear_velocity.length() > 0:
		var friction_force = -linear_velocity.normalized() * linear_friction * state.step
		if friction_force.length() > linear_velocity.length():
			linear_velocity = Vector2.ZERO
		else:
			linear_velocity += friction_force

	if abs(angular_velocity) > 0:
		var friction_torque = -sign(angular_velocity) * angular_friction * state.step
		if abs(friction_torque) > abs(angular_velocity):
			angular_velocity = 0
		else:
			angular_velocity += friction_torque

func shoot():
	var local_recoil_vector = Vector2(-cos(deg_to_rad(aiming_direction)), -sin(deg_to_rad(aiming_direction))) * recoil
	var global_recoil_vector = self.to_global(local_recoil_vector) - self.global_position

	apply_central_impulse(global_recoil_vector)
	
	var rotational_impact = aiming_direction * rotation_force
	angular_velocity -= rotational_impact
	
	animation_player.play("fire")
	await get_tree().create_timer(0.4).timeout
	animation_player.play("idle")
	
	shots_fired += 1
	if shots_fired >= 2:
		can_shoot = false
		shots_fired = 0
		reload_animation()
		await get_tree().create_timer(reload_time).timeout
		can_shoot = true
		animation_player.play("idle")
	else:
		can_shoot = true

func reload_animation():
	animation_player.play("reload")
