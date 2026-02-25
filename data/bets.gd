extends RefCounted
class_name BetsData

const BetCatalog = preload("res://scripts/content/bet_catalog.gd")

const BETS: Array[Dictionary] = BetCatalog.LEVEL3_BETS

static func level3_bets() -> Array[Dictionary]:
	return BetCatalog.level3_active_bets()

static func level3_bet_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for bet_id: StringName in BetCatalog.level3_active_bet_ids():
		ids.append(String(bet_id))
	return ids

