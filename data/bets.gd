const ARCH_DEBT: StringName = &"DEBT"
const ARCH_EGO: StringName = &"EGO"
const ARCH_TIME: StringName = &"TIME"

const BETS: Array[Dictionary] = [
	{
		"id": "CASH_OUT",
		"name": "INCASSA E VAI",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa bassa (placeholder)",
		"condition": "Vinci l'arena",
		"doom": "Nessuna condanna extra",
	},
	{
		"id": "FLAWLESS_BLOOD",
		"name": "SANGUE INTEGRO",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa alta (placeholder)",
		"condition": "Vinci l'arena senza subire danni",
		"doom": "HP massimo -20 (min 1) + cicatrice FERITA APERTA",
	},
	{
		"id": "DOUBLE_OR_DIE",
		"name": "RADDOPPI O MUORI",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa devastante (placeholder)",
		"condition": "Vinci l'arena",
		"doom": "MORTE IMMEDIATA: run terminata",
	},
]
