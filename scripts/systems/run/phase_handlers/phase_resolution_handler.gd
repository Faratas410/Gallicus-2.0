extends RunPhaseHandlerBase
class_name PhaseResolutionHandler

func build_ui_payload(_run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	return {
		"title": "RISOLUZIONE",
		"body": "L'arena decide il prezzo del patto.",
	}
