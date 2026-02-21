@tool
extends Node2D

@onready var sprite = $Sprite2D
@onready var climb_area = $ClimbArea
@onready var collision_shape = $ClimbArea/CollisionShape2D


@export var deploy_speed: float = 1.0 
@export var initial_length: float = 20.0

@export var height: float = 150.0:
	set(value):
		height = value
		_sync_shapes()

var is_deployed: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_deployment(height)
	else:
		_update_deployment(initial_length)

func _sync_shapes() -> void:
	if Engine.is_editor_hint():
		_update_deployment(height)


func deploy_rope() -> void:
	if Engine.is_editor_hint() or is_deployed:
		return
		
	is_deployed = true
	var tween = create_tween()
	tween.tween_method(_update_deployment, initial_length, height, deploy_speed)
	
func retract_rope() -> void:
	if Engine.is_editor_hint() or not is_deployed:
		return
		
	is_deployed = false
	var tween = create_tween()
	tween.tween_method(_update_deployment, height, initial_length, deploy_speed)


func _update_deployment(current_length: float) -> void:
	if not sprite or not collision_shape:
		return
		
	if sprite.region_enabled:
		sprite.region_rect.size.y = current_length
		
	if collision_shape.shape:
		collision_shape.shape.size.y = current_length
		collision_shape.shape.size.x = 75.0
		
	sprite.position.y = current_length / 2.0
	climb_area.position.y = current_length / 2.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		global_player.climbEntr.emit(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		global_player.climbLeave.emit(self)
