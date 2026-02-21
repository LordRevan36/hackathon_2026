extends Node2D

@export var travel_distance: Vector2 = Vector2(0, -200)
@export var speed: float = 100.0
@export var require_player : bool = true


@onready var platform = $MovingPlatform

var start_pos: Vector2
var target_pos: Vector2
var is_button_active: bool = false
var is_player_on: bool = false

func _ready() -> void:
	start_pos = platform.position 
	target_pos = start_pos + travel_distance

func _physics_process(delta: float) -> void:
	var destination = start_pos
	
	if is_button_active and (is_player_on or not require_player):
		destination = target_pos

	if platform.position != destination:
		platform.position = platform.position.move_toward(destination, speed * delta)


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player: 
		is_player_on = true

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_on = false


func _set_button_active() -> void:
	is_button_active = true


func _set_button_inactive() -> void:
	is_button_active = false
