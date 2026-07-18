extends CharacterBody2D

# 第一性原理：运动的本质是速度与时间的累加
@export var speed: float = 300.0
var move_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# 游戏开始时，给球一个随机的初始斜向角度 (弧度制)
	var random_angle = randf_range(0, 2 * PI)
	move_direction = Vector2.RIGHT.rotated(random_angle)

func _physics_process(delta: float) -> void:
	# 核心公式：速度 = 方向 * 速率
	velocity = move_direction * speed
	
	# move_and_slide() 是 Godot 处理碰撞的原子方法
	# 它会自动帮我们计算滑行，并在发生碰撞时返回相关数据
	var collided: bool = move_and_slide()
	
	if collided:
		# 第一性原理：弹射的本质是入射角等于反射角 (法线反射)
		# 拿到上一次碰撞的物理法线 (Normal)
		var collision_info = get_last_slide_collision()
		var normal = collision_info.get_normal()
		
		# 利用向量数学计算反射方向
		move_direction = move_direction.bounce(normal)
