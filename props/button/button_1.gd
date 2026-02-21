extends Area2D

@onready var collider = $Collider
@onready var sprite = $Sprite2D

enum State{ACTIVE, INACTIVE}

var state: State = State.INACTIVE
var bodies_on_button : int = 0

func _ready() -> void:
	state = State.INACTIVE
	_update_animation()

func _process(delta: float) -> void:
	pass

func _update_animation() -> void:
	match state:
		State.ACTIVE:
			sprite.play("active")
			sprite.position.y = 6
		State.INACTIVE:
			sprite.play("inactive")
			sprite.position.y = 0

func _update_state():
	if bodies_on_button == 0:
		state = State.INACTIVE
	else:
		state = State.ACTIVE
	_update_animation()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("box") or body.is_in_group("player"):
		bodies_on_button += 1
		_update_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("box") or body.is_in_group("player"):
		bodies_on_button -= 1
		_update_state()

func _get_button_state() -> bool:
	return state == State.ACTIVE
