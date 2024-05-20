extends Area2D

@export var speed = 1000.0
var velocity = Vector2.ZERO

func _ready():
	self.set_monitoring(true)
	

func _process(delta):
	position += velocity * delta

func _on_body_entered(body):
	pass
	#queue_free()  # Remove the projectile on collision
