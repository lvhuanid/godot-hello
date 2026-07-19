extends Area2D
# 可拾取道具：玩家进入范围时计分并销毁自身

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.collect_item()
		queue_free()
