extends Area2D

@export var speed = 1000.0
var velocity = Vector2.ZERO

func _ready():
	self.set_monitoring(true)
	

func _process(delta):
	position += velocity * delta

func _on_body_entered(body):
	print(body.name)
	if body.has_method("take_damage"):
		body.take_damage(10)
