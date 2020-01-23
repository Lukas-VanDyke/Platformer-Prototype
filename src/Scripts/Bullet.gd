extends KinematicBody2D

var velocity = Vector2()
var speed = 20

func _physics_process(delta):
	var collisionInfo = move_and_collide(velocity)
	if collisionInfo:
		get_parent().remove_child(self)
		queue_free()

func SetVelocity(newVelocity):
	velocity = newVelocity * speed