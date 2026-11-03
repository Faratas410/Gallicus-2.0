extends "res://tools/counter_layout_capture.gd"
## Headless entry for the same matrix used by rendered QA; no duplicate suite.
func _initialize() -> void:
	judgment_contract = true
	save_captures = false
	languages = [0, 1, 2]
	output = "res://artifacts/judgment_contract"
	super._initialize()
