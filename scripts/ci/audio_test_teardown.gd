extends RefCounted

# The dummy audio driver processes stop requests on its own real-time thread.
# Headless test frames can advance much faster than wall time, so a SceneTree
# timer alone cannot establish that the driver has released playback objects.
static func finish(tree: SceneTree) -> void:
	var bus := tree.root.get_node_or_null("SfxBus")
	if bus != null:
		bus.stop_all()
	var deadline := Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < deadline:
		await tree.process_frame
