extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0.0
	
	global_player.monsterGotPlayer.connect(_on_monster_got_player)

func _on_monster_got_player() -> void:
	fade_to_black(4.0)

func fade_to_black(duration: float) -> void:
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	
	tween.finished.connect(_on_fade_finished)

func _on_fade_finished() -> void:
	pass
