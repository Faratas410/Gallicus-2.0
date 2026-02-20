extends RefCounted
class_name RunFlowExecutor

const PhaseResultScript = preload("res://scripts/systems/run/phase_handlers/phase_result.gd")

var _hooks: RunFlowExecutorHooks = null
var _event_router: RunFlowEventRouter = null
var _mutation_registry: RunFlowMutationRegistry = null

func _init(hooks: RunFlowExecutorHooks, event_router: RunFlowEventRouter, mutation_registry: RunFlowMutationRegistry) -> void:
	_hooks = hooks
	_event_router = event_router
	_mutation_registry = mutation_registry

func apply_mutation_plan(res: PhaseResultScript) -> void:
	for step: Dictionary in res.mutation_plan:
		var step_type: String = str(step.get("type", ""))
		match step_type:
			"LOG":
				_hooks.log_fn.call(str(step.get("tag", "")), str(step.get("msg", "")))
			"AUTOSAVE":
				var checkpoint: StringName = StringName(str(step.get("checkpoint", "")))
				if checkpoint != &"":
					_hooks.autosave_fn.call(checkpoint)
			"SET_PHASE":
				var phase_value: int = int(step.get("phase", -1))
				if phase_value >= 0:
					_hooks.set_phase_fn.call(phase_value, "apply_mutation_plan")
			"EMIT_EVENT":
				_event_router.emit_by_name(str(step.get("name", "")), step.get("payload", {}) as Dictionary)
			"APPLY_STATE_MUTATION":
				_mutation_registry.apply(step)
			"END_RUN":
				_hooks.end_run_fn.call(str(step.get("reason", "")))
			_:
				_hooks.report_error_fn.call("Unknown mutation plan step: %s" % step_type)
				return
