extends RigidBody2D

@export var aiming_cone_angle = 60.0
@export var recoil = 100.0
@export var rotation_force = 0.1
@export var reload_time = 1.6
@export var linear_friction = 25.0
@export var angular_friction = 1.0
@export var tip_toe_interval = 1.0
@export var tip_toe_impulse = 1.5
@export var projectile_scene_path = "res://core/scenes/characters/projectile.tscn"
@export var fire_animation_time = 0.4
@export var magazine_size = 2
@export var pellets_per_shot = 5 
@export var spread_angle = 10.0

@onready var chair_sprite = $ChairSprite
@onready var player_sprite = $ChairSprite/PlayerSprite
@onready var animation_player = $AnimationPlayer
@onready var muzzle_flash = $ChairSprite/PlayerSprite/MuzzleFlash
@onready var muzzle_tip = $ChairSprite/PlayerSprite/MuzzleTip
@onready var fire_sound = $Fire
@onready var click_sound = $Click

var can_shoot = true
var aiming_direction = 0.0
var can_tip_toe = true
var shots_fired = 0
var bullets_loaded = magazine_size
var projectile_scene = null
var reloading = false

func _ready():
	projectile_scene = load(projectile_scene_path)
	animation_player.play("idle")

func _process(delta):
	handle_aiming(delta)
	handle_rotation(delta)
	if Input.is_action_just_pressed("shoot"):
		if can_shoot:
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
	if bullets_loaded <= 0:
		if not reloading:
			click_sound.play()
		return
	
	can_shoot = false
	
	muzzle_flash.visible = true
	animation_player.play("fire")
	fire_sound.play()
	fire_projectiles()

	var local_recoil_vector = Vector2(-cos(deg_to_rad(aiming_direction)), -sin(deg_to_rad(aiming_direction))) * recoil
	var global_recoil_vector = self.to_global(local_recoil_vector) - self.global_position
	apply_central_impulse(global_recoil_vector)
	
	var rotational_impact = aiming_direction * rotation_force
	angular_velocity -= rotational_impact

	await get_tree().create_timer(fire_animation_time).timeout
	muzzle_flash.visible = false

	bullets_loaded -= 1
	if bullets_loaded <= 0:
		reload_animation()
	else:
		can_shoot = true

func fire_projectiles():
	for i in range(pellets_per_shot):
		var projectile_instance = projectile_scene.instantiate()
		projectile_instance.position = muzzle_tip.global_position
		
		var spread = randf_range(-spread_angle / 2, spread_angle / 2)
		var global_rotation = player_sprite.global_rotation + deg_to_rad(spread)
		var direction = Vector2(cos(global_rotation), sin(global_rotation)).normalized()
		projectile_instance.velocity = direction * projectile_instance.speed
		
		get_parent().add_child(projectile_instance)

func reload_animation():
	reloading = true
	animation_player.play("reload")
	await get_tree().create_timer(reload_time).timeout
	bullets_loaded = magazine_size
	reloading = false
	can_shoot = true
	animation_player.play("idle")
