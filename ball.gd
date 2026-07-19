extends CharacterBody2D

# 第一性原理：运动的本质是速度与时间的累加
@export var speed: float = 300.0
var move_direction: Vector2 = Vector2.ZERO

# 撞击玩家后的冷却时间（避免一帧扣多条命）
const HIT_COOLDOWN := 1.0
var _hit_cooldown: float = 0.0

func _ready() -> void:
	_reset_position_and_direction()

func _physics_process(delta: float) -> void:
	# 冷却递减
	if _hit_cooldown > 0:
		_hit_cooldown -= delta

	# 核心公式：速度 = 方向 * 速率
	velocity = move_direction * speed
	var collided: bool = move_and_slide()

	if collided:
		# 弹射：入射角 = 反射角（法线反射）
		var collision_info = get_last_slide_collision()
		var normal = collision_info.get_normal()
		move_direction = move_direction.bounce(normal)

	_check_player_collision()

# 由 main.gd 在关卡切换时调用，提升球速
func set_speed(new_speed: float) -> void:
	speed = new_speed

func _check_player_collision() -> void:
	if _hit_cooldown > 0:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	# 简单距离检测（球 30 + 玩家 40 → 阈值约 35）
	if global_position.distance_to(player.global_position) < 35.0:
		GameManager.lose_life()
		_hit_cooldown = HIT_COOLDOWN
		_reset_position_and_direction()

func _reset_position_and_direction() -> void:
	global_position = Vector2(800, 324)
	var random_angle = randf_range(0, 2 * PI)
	move_direction = Vector2.RIGHT.rotated(random_angle)
