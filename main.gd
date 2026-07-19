extends Node2D
# 主场景逻辑：连接 GameManager 信号 → 更新 UI；生成道具；关卡推进加速球

@export var item_scene: PackedScene

@onready var ball: CharacterBody2D = $Ball
@onready var ui_score: Label = $UI/ScoreLabel
@onready var ui_lives: Label = $UI/LivesLabel
@onready var ui_level: Label = $UI/LevelLabel
@onready var ui_game_over: Label = $UI/GameOverLabel
@onready var ui_hint: Label = $UI/HintLabel

const BALL_BASE_SPEED := 300.0
const BALL_SPEED_PER_LEVEL := 50.0

# 游戏是否处于活动状态（false 时阻止道具生成）
var _game_active: bool = true

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.achievement_unlocked.connect(_on_achievement)
	GameManager.reset()
	ui_game_over.visible = false
	_spawn_item()

func _unhandled_input(event: InputEvent) -> void:
	# Game Over 后按 Enter / Space 重开
	if event.is_action_pressed("ui_accept") and ui_game_over.visible:
		_restart()

func _spawn_item() -> void:
	if not _game_active or not item_scene:
		return
	var item: Area2D = item_scene.instantiate()
	# 随机位置（避开墙边）
	item.global_position = Vector2(
		randf_range(80, 1100),
		randf_range(80, 600)
	)
	add_child(item)
	# 该道具被销毁后生成下一个
	item.tree_exited.connect(_spawn_item)

func _on_score_changed(new_score: int) -> void:
	ui_score.text = "Score: %d" % new_score

func _on_lives_changed(new_lives: int) -> void:
	ui_lives.text = "Lives: %d" % new_lives

func _on_level_changed(new_level: int) -> void:
	ui_level.text = "Level: %d" % new_level
	# 检查无伤成就（仅在新关开始时）
	GameManager.check_unscathed()
	# 球速随关卡递增
	var new_speed := BALL_BASE_SPEED + (new_level - 1) * BALL_SPEED_PER_LEVEL
	ball.set_speed(new_speed)

func _on_game_over() -> void:
	_game_active = false
	ui_game_over.text = "Game Over\nPress Enter / Space to restart"
	ui_game_over.visible = true
	# 停球，避免继续撞击玩家
	ball.set_speed(0.0)

func _on_achievement(title: String) -> void:
	ui_hint.text = "Achievement: %s" % title
	# 2.5 秒后清空提示
	get_tree().create_timer(2.5).timeout.connect(
		func(): if ui_hint: ui_hint.text = ""
	)

func _restart() -> void:
	# 清理所有已生成的道具
	for child in get_children():
		if child.name.begins_with("Item"):
			child.queue_free()
	GameManager.reset()
	_game_active = true
	ball.set_speed(BALL_BASE_SPEED)
	ui_game_over.visible = false
	# 稍延迟生成道具，确保旧道具已清理
	call_deferred("_spawn_item")
