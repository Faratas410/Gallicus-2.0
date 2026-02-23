extends RefCounted
class_name BetsData

const BetCatalog = preload("res://scripts/content/bet_catalog.gd")

const BETS: Array[Dictionary] = BetCatalog.LEVEL3_BETS

static func level3_bets() -> Array[Dictionary]:
	return BetCatalog.level3_bets()

static func level3_bet_ids() -> PackedStringArray:
	return BetCatalog.level3_bet_ids()

