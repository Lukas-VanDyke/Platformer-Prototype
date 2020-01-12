extends KinematicBody2D

export (int) var movementSpeed = 300
export (int) var maxSpeed = 200
export (int) var climbingSpeed = 100
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func get_input():
	velocity.x = 0
	if Input.is_action_pressed("left"):
		velocity.x -= movementSpeed
	if Input.is_action_pressed("right"):
		velocity.x += movementSpeed
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jumpSpeed
