extends CharacterBody2D
class_name Player

#do this for any child nodes you want to call - makes it so that if the tree organization changes, the node call can be easily updated
@onready var player_sprite = $PlayerSprite
@onready var player_hitbox = $PlayerHitbox

var JUMP_CONSTANT = 300
var WALK_CONSANT = 100

enum State {IDLE, JUMP, LAND, WALK, RUN}

var state : State = State.IDLE
var direction


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * global_constants.GRAVITY_MULTIPLIER
	
	
	#direction = Input.get_axis("left", "right")
	#-1 left +1 right
	
	#each thing inside these if and elifs should be their own functions and better written but I was rushed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#jump animation is getting cut off somehow, gotta figure out why
		velocity += Vector2(0, -JUMP_CONSTANT)
		state = State.JUMP
		_update_animations()
	elif is_on_floor() and state == State.JUMP:
		#state = State.LAND - this wouldn't do anything atm but have it here in case
		global_player.landed.emit()
		state = State.IDLE
		_update_animations()
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		direction = Input.get_axis("left", "right")
		state = State.WALK
		#velocity.x = move_toward(velocity.x, 0, direction * WALK_CONSANT)
		velocity.x = direction * WALK_CONSANT
		_update_animations()
	elif not Input.is_anything_pressed() and state != State.JUMP:
		state = State.IDLE
		_update_animations()
	
	if state == State.IDLE:
		velocity.x = 0
	move_and_slide()

func _update_animations() -> void:
	if direction == 1:
		player_sprite.flip_h = false
	else:
		player_sprite.flip_h = true
	match state:
		State.IDLE:
			player_sprite.play("idle")
		State.JUMP:
			player_sprite.play("jump")
		State.WALK:
			player_sprite.play("walk")
