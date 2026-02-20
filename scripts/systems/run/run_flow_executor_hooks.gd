extends RefCounted
class_name RunFlowExecutorHooks

var log_fn: Callable
var autosave_fn: Callable
var set_phase_fn: Callable
var end_run_fn: Callable
var report_error_fn: Callable

func _init(
	log_fn_in: Callable,
	autosave_fn_in: Callable,
	set_phase_fn_in: Callable,
	end_run_fn_in: Callable,
	report_error_fn_in: Callable
) -> void:
	log_fn = log_fn_in
	autosave_fn = autosave_fn_in
	set_phase_fn = set_phase_fn_in
	end_run_fn = end_run_fn_in
	report_error_fn = report_error_fn_in
