extends "res://scripts/ci/campaign_runtime_contract.gd"

# A second real journey reads crowd intents, buys affordable services and pursues
# the bando. The inherited test still controls only clocks and initial seeds.
var purchases: int = 0

func _press(button_name: String) -> bool:
	if button_name == "Btn_Open_Book" and _available(button_name):
		var view: Dictionary = manager.get_banco_view()
		for item: Dictionary in view.items:
			if not bool(item.available): continue
			var bank_button: String = "Btn_Banco_" + str(item.id)
			if not _available(bank_button): continue
			var before: int = int(manager.get_banco_view().denari)
			if super._press(bank_button):
				var after: int = int(manager.get_banco_view().denari)
				if before - after != int(item.price): _fail("bank charged a different price")
				purchases += 1
				print("REVIEW_PURCHASE ", item.id, " price=", item.price, " before=", before, " after=", after)
				# Buy one service per arena, then keep the rest for the next.
				break
	if button_name == "Btn_MID_CHOICE_SELECT_0" and _available(button_name):
		var exchange: Dictionary = manager.get_crowd_exchange_view()
		if str(exchange.get("intent", "")) in ["blood", "bored"]:
			return super._press("Btn_MID_CHOICE_SELECT_1")
	if button_name in ["Btn_PUSH_YOUR_LUCK_DOUBLE", "Btn_PUSH_YOUR_LUCK_CASHOUT"] and _available(button_name):
		var live: RunState = manager.get("_run_state")
		var quota: Dictionary = manager.get_bando_view()
		var pursue: bool = live.stake_glory < int(quota.get("quota", 0)) and live.arena_index < int(quota.get("deadline", 0))
		if button_name == "Btn_PUSH_YOUR_LUCK_CASHOUT" and pursue: return false
		if button_name == "Btn_PUSH_YOUR_LUCK_DOUBLE" and not pursue and _available("Btn_PUSH_YOUR_LUCK_CASHOUT"): return false
	return super._press(button_name)

func _capture(label: String) -> void:
	if label == "departure":
		for tale: Dictionary in Dialogues.TALES:
			if not dialogues_seen.has(str(tale.id)): _fail("bando journey missed tale " + str(tale.id))
		if purchases == 0: _fail("bando journey never purchased a bank service")
		print("REVIEW_PURCHASES=", purchases)
	await super._capture(label)
