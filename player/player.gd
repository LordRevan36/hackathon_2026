extends CharacterBody2D
class_name Player

#do this for any child nodes you want to call - makes it so that if the tree organization changes, the node call can be easily updated
@onready var player_sprite = $PlayerSprite
@onready var player_hitbox = $PlayerHitbox

@export var JUMP_CONSTANT = 650.0
@export var RUN_CONSTANT = 250.0
@export var AIR_ACCEL: float = 1000.0 # How fast you change direction in the air
@export var AIR_FRICTION: float = 100.0 # How fast you slow down when you let go in the air

enum State {IDLE, JUMP, LAND, WALK, RUN, CLIMB, FALL, DEAD}

var ON_LADDER = false
var state : State = State.IDLE
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_player.fellToDeath.connect(_falling_to_death)
	global_player.climbEntr.connect(ladderCtrl)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_apply_gravity(delta)
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)
		move_and_slide()
		return
	
	_apply_gravity(delta)
	
	_handle_movement(delta)
	_handle_jump()
	
	move_and_slide()
	
	_update_states()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var player_gravity_multiplier = 1.3 if velocity.y < 0 else 1.0
		velocity.y += get_gravity().y * delta * global_constants.GRAVITY_MULTIPLIER * player_gravity_multiplier

func _handle_movement(delta: float) -> void:
	var direction = Input.get_axis("left","right")
	#-1 = left, +1 = right, 0 = neither
	if direction != 0:
		player_sprite.flip_h = direction < 0
	if is_on_floor():
		velocity.x = direction * RUN_CONSTANT
	else:
		if direction != 0:
			var target_speed = RUN_CONSTANT * direction
			#slowed by friction if trying to move in same direction as current
			if abs(velocity.x) > RUN_CONSTANT and sign(velocity.x) == sign (direction):
				velocity.x = move_toward(velocity.x, target_speed, AIR_FRICTION * delta)
			#player pushes themself in direction they want
			else:
				velocity.x = move_toward(velocity.x, target_speed, AIR_ACCEL * delta)
		#player slows toward zero by friction if not pressing
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_CONSTANT
		
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider and collider.get_parent().is_in_group("swinging_platform"):
				var inherited_momentum = collider.get_parent()._get_swing_velocity()
				inherited_momentum.x /= 2
				velocity += inherited_momentum

func _update_states() -> void:
	var previous_state = state
	if previous_state == State.DEAD:
		return
	if not is_on_floor():
		if velocity.y < 0:
			state = State.JUMP
		else:
			state = State.FALL
	elif velocity.x != 0:
		state = State.RUN
	else:
		state = State.IDLE
	if state != previous_state:
		_update_animations()

func _update_animations() -> void:
	match state:
		State.IDLE:
			player_sprite.play("idle")
		State.JUMP:
			player_sprite.play("jump")
		State.RUN:
			player_sprite.play("run")
		State.FALL:
			player_sprite.play("fall")
		State.DEAD:
			player_sprite.play("death")

func _falling_to_death() -> void:
	if state != State.DEAD:
		state = State.DEAD
		_update_animations()
		
#ladder bs starts here

#functions to check if you're on a ladder or not
#func _on_ladder_1_body_entered(body: Node2D) -> void:
	#ON_LADDER = true
	#print("debug on")
#func _on_ladder_1_body_exited(body: Node2D) -> void:
	#ON_LADDER = false
	#print("debug off")
func ladderCtrl(ladderPos: int) -> bool:
	position.x = ladderPos
	velocity.y = 0
	if Input.is_action_just_pressed("jump"):
		position.y += -20
		return(true)
	elif Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or !ON_LADDER:
		state = State.IDLE
		return(false)
	else:
		return(true)
