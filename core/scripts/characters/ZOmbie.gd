extends CharacterBody2D

@export var speed = 40 
@export var health = 100

@onready var bloodSFX = $DeathSFX

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

var blood = load("res://core/scenes/characters/bloodFX.tscn")

func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = player.global_position


func _on_timer_timeout():
	makepath()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		var blood_instance = blood.instantiate()
		get_tree().current_scene.add_child(blood_instance)
		
		bloodSFX.play()
		
		blood_instance.global_position = global_position
		blood_instance.rotation = global_position.angle_to_point(player.global_position) - deg_to_rad(180)
		
		die()

func die() -> void:
	queue_free()
