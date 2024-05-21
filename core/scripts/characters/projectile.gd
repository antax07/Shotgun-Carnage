extends Area2D

@export var speed = 600.0
var velocity = Vector2.ZERO

func _ready():
	self.set_monitoring(true)
	

func _process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(5)
