extends KinematicBody2D

export (int) var movementSpeed = 500
export (int) var climbingSpeed = 100
export (int) var wallSlideSpeed = 200
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()

var grappling = false
var grapplingTarget

func _physics_process(delta):
	if grappling:
		velocity = (grapplingTarget - global_position).normalized() * movementSpeed
		if (grapplingTarget - global_position).length() > 33:
			velocity = move_and_slide(velocity)
		else:
			grappling = false
		return
	
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
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
		
	if Input.is_action_just_pressed("click"):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, get_global_mouse_position(), [self])
		if result:
			grapplingTarget = result.position
			grappling = true
