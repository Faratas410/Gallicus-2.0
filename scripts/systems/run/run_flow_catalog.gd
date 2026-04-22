extends RefCounted
class_name RunFlowCatalog

class Bundle:
	extends RefCounted
	var event_router: RunFlowEventRouter
	var mutation_registry: RunFlowMutationRegistry

func build_bundle(run_manager: Node) -> Bundle:
	var bundle: Bundle = Bundle.new()
	bundle.event_router = RunFlowEventRouter.new()
	bundle.mutation_registry = RunFlowMutationRegistry.new()
	_register_events(bundle.event_router, run_manager)
	_register_mutations(bundle.mutation_registry, run_manager)
	return bundle

func _register_events(_router: RunFlowEventRouter, _run_manager: Node) -> void:
	# No mutation-plan EMIT_EVENT names are currently active in phase handler plans.
	# Keep router surface minimal and fail-fast on unknown names.
	pass

func _register_mutations(registry: RunFlowMutationRegistry, run_manager: Node) -> void:
	registry.register_handler("PYL_CASHOUT", Callable(run_manager, "_mut_pyl_cashout"))
	registry.register_handler("PYL_CONDANNA", Callable(run_manager, "_mut_pyl_condanna"))
	registry.register_handler("PYL_DOUBLE", Callable(run_manager, "_mut_pyl_double"))
	registry.register_handler("BETP_PLACE_BET", Callable(run_manager, "_mut_betp_place_bet"))
	registry.register_handler("INTRO_SELECT_BET", Callable(run_manager, "_mut_intro_select_bet"))
	registry.register_handler("INTRO_CONFIRM", Callable(run_manager, "_mut_intro_confirm"))
	registry.register_handler("INTM_SELECT", Callable(run_manager, "_mut_intm_select"))
	registry.register_handler("GAMEOVER_SHOW_MENU", Callable(run_manager, "_mut_gameover_show_menu"))
	registry.register_handler("GAMEOVER_RESTART", Callable(run_manager, "_mut_gameover_restart"))
	registry.register_handler("MAINMENU_NEW_RUN", Callable(run_manager, "_mut_mainmenu_new_run"))
	registry.register_handler("MAINMENU_CONTINUE_RUN", Callable(run_manager, "_mut_mainmenu_continue_run"))
	registry.register_handler("MAINMENU_SHOW_MENU", Callable(run_manager, "_mut_mainmenu_show_menu"))
