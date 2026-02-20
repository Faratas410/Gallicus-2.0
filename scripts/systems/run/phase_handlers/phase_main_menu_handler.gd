extends RunPhaseHandlerBase
class_name PhaseMainMenuHandler


func can_accept_request(request_name: String) -> bool:
	match request_name:
		"request_continue_run":
			return true
		"request_new_run":
			return true
		"request_show_main_menu":
			return true
		_:
			return false

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	match request_name:
		"request_new_run":
			res.action = "MAINMENU_NEW_RUN"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "MAINMENU_NEW_RUN"})
		"request_continue_run":
			res.action = "MAINMENU_CONTINUE_RUN"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "MAINMENU_CONTINUE_RUN"})
		"request_show_main_menu":
			res.action = "MAINMENU_SHOW_MENU"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "MAINMENU_SHOW_MENU"})
		_:
			res.handled = false
	return res
