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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if not is_on_floor():
			if velocity.y < 0:
				velocity += get_gravity() * delta * global_constants.GRAVITY_MULTIPLIER * 1.3
			else:
				velocity += get_gravity() * delta * global_constants.GRAVITY_MULTIPLIER
				
		#direction = Input.get_axis("left", "right")
	#	-1 left +1 right
		#each thing inside these if and elifs should be their own functions and better written but I was rushed
		if Input.is_action_just_pressed("jump") and is_on_floor():
			#jump animation is not ideal - it needs separated into jumping up and the actual landing bit or smth
			velocity += Vector2(0, -JUMP_CONSTANT)
			state = State.JUMP
			_update_animations()
		elif is_on_floor() and state == State.JUMP:
			#state = State.LAND - this wouldn't do anything atm but have it here in case
			global_player.landed.emit()
			state = State.IDLE
			_update_animations()
		elif (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			direction = Input.get_axis("left", "right")
			if is_on_floor():
				state = State.RUN
				_update_animations()
			else:
				player_sprite.flip_h = direction < 0
			#velocity.x = move_toward(velocity.x, 0, direction * RUN_CONSTANT) 
			velocity.x = direction * RUN_CONSTANT
			
		elif not Input.is_anything_pressed() and state != State.JUMP:
			state = State.IDLE
			_update_animations()
		
		if state == State.IDLE:
			velocity.x = 0
		move_and_slide()

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
