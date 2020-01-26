extends KinematicBody2D

onready var grapplingHook = load("res://Scenes/Gadgets/GrapplingHook.tscn")
onready var grappleLine = load("res://Scenes/Gadgets/GrappleLine.tscn")
onready var bullet = load("res://Scenes/Projectiles/Bullet.tscn")
onready var slash = load("res://Scenes/Melee/Slash.tscn")

export (int) var movementSpeed = 400
export (int) var grapplingSpeed = 1000
export (int) var climbingSpeed = 100
export (int) var wallSlideSpeed = 200
export (int) var gravity = 2500
export (int) var jumpSpeed = -1000

var velocity = Vector2()

var rightWall = false
var leftWall = false

var facingRight = true

var doubleJumpUsed = false
var dashUsed = false
var dashing = false
var dashTimer = 0

var wallJumpCount = 0

var grappling = false
var grapplingTarget
var previousPosition = Vector2()

var hook
var line
var pin
var slashTimer = 2

func _physics_process(delta):
	if slashTimer < 0.5:
		slashTimer += delta
		return
	
	if dashing:
		dashTimer += (5 * delta)
		if dashTimer > 1:
			dashing = false
		else:
			velocity = Vector2(4 * movementSpeed, 0)
			if not facingRight:
				velocity.x *= -1
			
			Move()
			return
	
	if line != null:
		line.points[0] = global_position
	
	if grappling:
		if (previousPosition - global_position).length() < 3:
			grappling = false
			if hook != null:
				get_parent().remove_child(hook)
				hook.queue_free()
				hook = null
			if line != null:
				get_parent().remove_child(line)
				line.queue_free()
				line = null
		
		previousPosition = global_position
		velocity = (grapplingTarget - global_position).normalized() * grapplingSpeed
		if (grapplingTarget - global_position).length() > 33:
			velocity = move_and_slide(velocity)
		else:
			grappling = false
			if hook != null:
				get_parent().remove_child(hook)
				hook.queue_free()
				hook = null
			if line != null:
				get_parent().remove_child(line)
				line.queue_free()
				line = null
		return
	
	if wallJumpCount > 0:
		wallJumpCount -= 1
	else:
		get_input()
	velocity.y += gravity * delta
	if is_on_wall():
		if velocity.y > wallSlideSpeed:
			velocity.y = wallSlideSpeed
	
	if velocity.x > 0:
		facingRight = true
	if velocity.x < 0:
		facingRight = false
	
	Move()
	
		
func Move():
	velocity = move_and_slide(velocity, Vector2.UP)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.get_collision_layer() == 128:
			get_parent().ResetPlayer()
		if collision.collider.get_collision_layer() == 1024:
			get_parent().End()
			
		SetWall(collision.normal)
			
func SetWall(collisionNormal):
	rightWall = false
	leftWall = false
	
	if collisionNormal == Vector2(1, 0):
		rightWall = true
	elif collisionNormal == Vector2(-1, 0):
		leftWall = true
	
func get_input():
	VelocityCheck()
	
	if is_on_floor() or is_on_wall():
		doubleJumpUsed = false
		dashUsed = false
	
	if velocity.x < 0:
		if velocity.x < (-1) * (movementSpeed / 10):
			velocity.x += (movementSpeed / 10)
		else:
			velocity.x = 0
	elif velocity.x > 0:
		if velocity.x > (movementSpeed / 10):
			velocity.x -= (movementSpeed / 10)
		else:
			velocity.x = 0
	
	if Input.is_action_pressed("left"):
		velocity.x -= movementSpeed / 5
	if Input.is_action_pressed("right"):
		velocity.x += movementSpeed / 5
	if Input.is_action_just_pressed("space") and (is_on_floor() or is_on_wall() or not doubleJumpUsed):
		velocity.y = jumpSpeed
		if (not is_on_floor() and not is_on_wall()):
			doubleJumpUsed = true
		else:
			if rightWall:
				velocity.x += (movementSpeed * 5)
				VelocityCheck()
				wallJumpCount = 6
			if leftWall:
				velocity.x -= (movementSpeed * 5)
				VelocityCheck()
				wallJumpCount = 6
			
		
	if Input.is_action_just_released("space"):
		if velocity.y < 0:
			velocity.y += 300
		
	if Input.is_action_just_pressed("click"):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, get_global_mouse_position(), [self])
		if result and hook == null:
			SendGrapple(result.position)
			
	if Input.is_action_just_pressed("grapple_launch"):
		var space_state = get_world_2d().direct_space_state
		var direction = Vector2()
		direction.x = -Input.get_action_strength("right_stick_left") + Input.get_action_strength("right_stick_right")
		direction.y = -Input.get_action_strength("right_stick_up") + Input.get_action_strength("right_stick_down")
		
		var start = global_position
		var target = start + (1000 * direction)
		var result = space_state.intersect_ray(global_position, target, [self])
		if result and hook == null:
			SendGrapple(result.position)
			
	if Input.is_action_just_pressed("shoot"):
		Shoot()
		
	if Input.is_action_just_pressed("melee"):
		Slash()
		
	if Input.is_action_just_pressed("dash") and not dashUsed:
		dashing = true
		dashUsed = true
		dashTimer = 0
			
func VelocityCheck():
	if velocity.x > movementSpeed:
		velocity.x = movementSpeed
	if velocity.x < (-1) * movementSpeed:
		velocity.x = (-1) * movementSpeed

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
	
func Shoot():
	var newBullet = bullet.instance()
	var bulletVelocity = Vector2(1, 0)
	var offset = 38
	if not facingRight:
		bulletVelocity.x *= -1
		offset *= -1
		
	newBullet.SetVelocity(bulletVelocity)
	var bulletPosition = global_position
	bulletPosition.x += offset
	newBullet.set_global_position(bulletPosition)
	get_parent().add_child(newBullet)
	
func Slash():
	slashTimer = 0
	var newSlash = slash.instance()
	var offset = 40
	if not facingRight:
		newSlash.flip()
		offset *= -1
		
	var slashPosition = global_position
	slashPosition.x += offset
	newSlash.set_global_position(slashPosition)
	get_parent().add_child(newSlash)