extends Node
# 全局游戏状态管理器（autoload 单例）
# 最小化实现：仅维护核心数值与信号，不引入额外架构

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)
signal game_over()
signal achievement_unlocked(title: String)

const ITEMS_PER_LEVEL := 5
const MAX_LIVES := 3

var score: int = 0
var lives: int = MAX_LIVES
var level: int = 1
var items_collected_this_level: int = 0

# 成就：以字典记录解锁状态，避免重复触发
var _achievements: Dictionary = {
	"first_blood": false,
	"centurion": false,
	"survivor": false,
	"unscathed": false,
}

func reset() -> void:
	score = 0
	lives = MAX_LIVES
	level = 1
	items_collected_this_level = 0
	_achievements = {
		"first_blood": false,
		"centurion": false,
		"survivor": false,
		"unscathed": false,
	}
	emit_signal("score_changed", score)
	emit_signal("lives_changed", lives)
	emit_signal("level_changed", level)

func collect_item() -> void:
	items_collected_this_level += 1
	add_score(10)
	_unlock("first_blood", "First Blood: 拾取第一个道具")
	if items_collected_this_level >= ITEMS_PER_LEVEL:
		level_up()

func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_changed", score)
	if score >= 100:
		_unlock("centurion", "Centurion: 累计得分 100+")

func lose_life() -> void:
	lives -= 1
	emit_signal("lives_changed", lives)
	if lives <= 0:
		emit_signal("game_over")

func level_up() -> void:
	level += 1
	items_collected_this_level = 0
	emit_signal("level_changed", level)
	if level >= 3:
		_unlock("survivor", "Survivor: 到达第 3 关")

# 玩家通关一关且未受伤 → 解锁无伤成就（由 main.gd 在关卡切换时调用）
func check_unscathed() -> void:
	if lives >= MAX_LIVES:
		_unlock("unscathed", "Unscathed: 一关无伤通关")

func _unlock(key: String, title: String) -> void:
	if _achievements.get(key, true):
		return
	_achievements[key] = true
	emit_signal("achievement_unlocked", title)
