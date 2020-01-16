extends KinematicBody2D

onready var grapplingHook = load("res://Scenes/Gadgets/GrapplingHook.tscn")
onready var grappleLine = load("res://Scenes/Gadgets/GrappleLine.tscn")

export (int) var movementSpeed = 500
export (int) var grapplingSpeed = 1000
export (int) var climbingSpeed = 100
export (int) var wallSlideSpeed = 200
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()

var leftWall = false
var rightWall = false
var floored = false

var grappling = false
var grapplingTarget
var previousPosition = Vector2()

var hook
var line

func _physics_process(delta):
	if line != null:
		line.points[0] = global_position
	
	if grappling:
		if (previousPosition - global_position).length() < 3:
			grappling = false
			get_parent().remove_child(hook)
			hook.queue_free()
			hook = null
			get_parent().remove_child(line)
			if line != null:
				line.queue_free()
				line = null
		
		previousPosition = global_position
		velocity = (grapplingTarget - global_position).normalized() * grapplingSpeed
		if (grapplingTarget - global_position).length() > 33:
			velocity = move_and_slide(velocity)
		else:
			grappling = false
			get_parent().remove_child(hook)
			hook.queue_free()
			hook = null
			get_parent().remove_child(line)
			if line != null:
				line.queue_free()
				line = null
		return
	
	get_input()
	velocity.y += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.normal
		var remainder = collision.remainder
		var horizontal_movement = abs(remainder.x)
		
		velocity.y = Vector2(0, velocity.y).slide(normal).y
		
		var remaining_movement = remainder.slide(normal)
		remaining_movement = remaining_movement.normalized()
		remaining_movement *= horizontal_movement
		if (leftWall or rightWall) and velocity.y > 0:
			remaining_movement /= 2
		move_and_collide(remaining_movement)
		
		SetColliders(normal)
		
		if collision.collider.get_collision_layer() == 128:
			get_parent().ResetPlayer()
	else:
		SetColliders(Vector2(0, 0))
	
func SetColliders(normal):
	floored = false
	leftWall = false
	rightWall = false
	
	if normal == Vector2(-1, 0):
		leftWall = true
	elif normal == Vector2(1, 0):
		rightWall = true
	elif normal == Vector2(0, -1):
		floored = true
	
func get_input():
	velocity.x = 0
	
	if Input.is_action_pressed("left"):
		velocity.x -= movementSpeed
	if Input.is_action_pressed("right"):
		velocity.x += movementSpeed
	if Input.is_action_just_pressed("space") and (floored or leftWall or rightWall):
		velocity.y = jumpSpeed
	if Input.is_action_just_released("space"):
		if velocity.y < 0:
			velocity.y += 300
		
	if Input.is_action_just_pressed("click"):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, get_global_mouse_position(), [self])
		if result and hook == null:
			SendGrapple(result.position)

func SendGrapple(targetPosition):
	hook = grapplingHook.instance()
	get_parent().add_child(hook)
	
	line = grappleLine.instance()
	line.points[0] = global_position
	line.points[1] = global_position
	get_parent().add_child(line)
	
	hook.set_global_position(global_position)
	hook.SetVelocity(targetPosition, line)
	hook.connect("grapple_hit", self, "StartGrapple")
	
func StartGrapple(grapplePosition):
	grapplingTarget = grapplePosition
	grappling = true