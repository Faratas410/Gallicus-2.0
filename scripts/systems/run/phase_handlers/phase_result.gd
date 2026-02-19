extends RefCounted
class_name PhaseResult

# Il handler descrive cosa fare, RunManager esegue.
# Nessuna authority nel handler.

var handled: bool = false
var reason: String = ""

# "intent" che RunManager interpreterà in modo deterministico.
# Esempi: "CASHOUT", "DOUBLE", "PLACE_BET", "MID_CHOICE"
var action: String = ""

# Payload UI opzionale (già conforme alle chiavi esistenti)
var ui_payload: Dictionary = {}

# Eventi da emettere (solo nomi), RunManager emette e in ordine.
var emit_events: Array[String] = []

# Next phase richiesta (int RunPhase). RunManager decide se applicarla.
var next_phase: int = -1
