extends KinematicBody2D

export (int) var movementSpeed = 300
export (int) var climbingSpeed = 100

var velocity = Vector2()

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	
func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("left"):
		velocity.x = velocity.x - 1
	if Input.is_action_pressed("right"):
		velocity.x = velocity.x + 1
	
	velocity = velocity.normalized() * movementSpeed
