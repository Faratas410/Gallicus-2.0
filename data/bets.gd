const BETS: Array[Dictionary] = [
	{
		"id": "SAFE",
		"label": "SAFE BET",
		"condition": "Win the arena",
		"benefit": "Small coin payout",
		"failure": "Lose the stake",
		"odds": 1.2,
	},
	{
		"id": "RISK",
		"label": "RISK BET",
		"condition": "Win the arena without taking damage",
		"benefit": "High coin payout",
		"failure": "Permanent max HP -10 this run",
		"odds": 2.4,
	},
	{
		"id": "DESTINY",
		"label": "DESTINY BET",
		"condition": "Win the arena without taking damage",
		"benefit": "Very high coin payout",
		"failure": "Run ends immediately",
		"warning": "WARNING: Failure ends the run.",
		"odds": 4.0,
	},
]
