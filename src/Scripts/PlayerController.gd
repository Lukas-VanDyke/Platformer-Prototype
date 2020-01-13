extends KinematicBody2D

export (int) var movementSpeed = 500
export (int) var climbingSpeed = 100
export (int) var wallSlideSpeed = 200
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()
var look_direction = Vector2(1,0)

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	UpdateLookDirection()
	
func get_input():
	velocity.x = 0
	if is_on_wall():
		if velocity.y > wallSlideSpeed:
			velocity.y = wallSlideSpeed
	
	if Input.is_action_pressed("left"):
		velocity.x -= movementSpeed
	if Input.is_action_pressed("right"):
		velocity.x += movementSpeed
	if Input.is_action_just_pressed("space") and (is_on_floor() or is_on_wall()):
		velocity.y = jumpSpeed
		
func UpdateLookDirection():
	look_direction = velocity
