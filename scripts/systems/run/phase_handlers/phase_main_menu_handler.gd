extends RunPhaseHandlerBase
class_name PhaseMainMenuHandler

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if request_name == "request_new_run":
		res.handled = true
		res.action = "NEW_RUN"
		return res
	if request_name == "request_continue_run":
		res.handled = true
		res.action = "CONTINUE_RUN"
		return res
	if request_name == "request_show_main_menu":
		res.handled = true
		res.action = "SHOW_MAIN_MENU"
		return res
	return res
