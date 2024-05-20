extends RigidBody2D

@export var speed = 100 
var player = RigidBody2D

func _ready():
	player = get_node("../Player")

func _process(_delta):
	var direction = (player.global_position - global_position).normalized()
	
	var force = direction * speed
	
	apply_central_impulse(force)
