extends CharacterBody2D

# 玩家角色：通过键盘输入控制移动
@export var speed: float = 400.0

func _physics_process(_delta: float) -> void:
	# 读取键盘输入（方向键 / WASD 需在 Input Map 中配置）
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
