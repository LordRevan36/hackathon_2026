@tool
extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D

@export var height : float = 150.0:
	set(value):
		height = value
		_sync_shapes()

func _ready() -> void:
	_sync_shapes()

func _process(delta: float) -> void:
	pass
	#if not Engine.is_editor_hint():
		#if monitoring == true and get_overlapping_bodies()[0] == Player:
			#print("Debug")
			#global_player.climbEntr.emit(self.position.x)

func _sync_shapes() -> void:
	if not sprite or not collision_shape:
		return
	if sprite.region_enabled:
		sprite.region_rect.size.y = height
	if collision_shape.shape:
		collision_shape.shape.size.y = height
		collision_shape.shape.size.x = 75.0
	sprite.position = Vector2.ZERO
	collision_shape.position = Vector2.ZERO


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		global_player.climbEntr.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		global_player.climbLeave.emit(self)
