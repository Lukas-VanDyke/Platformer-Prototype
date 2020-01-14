extends KinematicBody2D

var velocity = Vector2()
var targetPosition
var speed = 20

var hit = false

signal grapple_hit(collision_position)

func _physics_process(delta):
	if hit:
		return
	
	velocity = (targetPosition - global_position).normalized() * speed
	var collisionInfo = move_and_collide(velocity)
	if collisionInfo:
		velocity = Vector2(0, 0)
		hit = true
		emit_signal("grapple_hit", collisionInfo.position)
	
func SetVelocity(target):
	look_at(target)
	rotate(90 * 0.0174533)
	targetPosition = target
