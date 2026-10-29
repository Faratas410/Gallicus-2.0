extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save = root.get_node("SaveManager")
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "witness", "era": 1}
	meta["seat_inquiry"] = {"seen": 3, "complete": true}
	meta["seat_copy"] = "copy"
	meta["seat_copy_era"] = 1
	meta["ledger_denari"] = 27
	save.reset_campaign()
	if save.get_seat_case().choice != "" or int(save.get_seat_inquiry().seen) != 0 or save.get_seat_copy() != "" or save.get_seat_copy_era() != -1 or save.get_ledger_denari() != 0:
		push_error("SEAT_RESET_ALIGNMENT: campaign data survived reset")
		quit(1)
		return
	save.set("_profile_loaded", false)
	save.load_profile()
	if save.get_seat_case().choice != "" or int(save.get_seat_inquiry().seen) != 0 or save.get_seat_copy() != "" or save.get_seat_copy_era() != -1 or save.get_ledger_denari() != 0:
		push_error("SEAT_RESET_ALIGNMENT: campaign data survived reload")
		quit(1)
		return
	print("SEAT_RESET_ALIGNMENT_OK")
	quit(0)
