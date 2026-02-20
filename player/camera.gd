extends Camera2D

@onready var player = $"../Player"
@onready var leftWall = $"LeftWall"
@onready var rightWall = $"RightWall"
@onready var leftCollider = $"LeftWall/CollisionShape2D"
@onready var rightCollider = $"RightWall/CollisionShape2D"

static var SCROLL_CONSTANT = 15
static var PLAYER_CATCH_CONSTANT = -200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leftCollider.shape.set_a(Vector2(0, -global_constants.SCREEN_HEIGHT/2))
	leftCollider.shape.set_b(Vector2(0, global_constants.SCREEN_HEIGHT/2))
	rightCollider.shape.set_a(Vector2(0, -global_constants.SCREEN_HEIGHT/2))
	rightCollider.shape.set_b(Vector2(0, global_constants.SCREEN_HEIGHT/2))
	leftWall.position = Vector2(-global_constants.SCREEN_WIDTH/2, 0)
	rightWall.position = Vector2(global_constants.SCREEN_WIDTH/2, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#slow constant scroll up
	#position.y = position.y - delta * SCROLL_CONSTANT
	#follow player up, don't follow player back down
	if player.position.y < position.y:
		position.y = player.position.y
	#follow player to their death
	if player.position.y > position.y + global_constants.SCREEN_HEIGHT/2 - PLAYER_CATCH_CONSTANT:
		position.y = player.position.y - global_constants.SCREEN_HEIGHT/2 + PLAYER_CATCH_CONSTANT
		global_player.fellToDeath.emit()
