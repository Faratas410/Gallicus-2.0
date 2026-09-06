extends SceneTree

var _paths: Array[String] = []
var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_inspect")

func _walk(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		return
	for name: String in directory.get_files():
		_paths.append(path.path_join(name))
	for name: String in directory.get_directories():
		_walk(path.path_join(name))

func _inspect() -> void:
	_walk("res://")
	_paths.sort()
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui/generated/manifest.json"))
	if not manifest is Dictionary or not manifest.get("assets") is Array:
		push_error("Export has no valid original art manifest")
		quit(1)
		return
	var allowed_imports: Array[String] = []
	var allowed_textures: Array[String] = []
	for asset: Dictionary in manifest["assets"]:
		var source: String = str(asset.get("path", ""))
		var imported: ConfigFile = ConfigFile.new()
		if imported.load(source + ".import") != OK:
			_failures.append("Missing import mapping: " + source)
			continue
		allowed_imports.append(source + ".import")
		allowed_textures.append(str(imported.get_value("remap", "path", "")))
		var texture: Texture2D = load(source) as Texture2D
		if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
			_failures.append("Image does not load: " + source)
	var audio_manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/original/manifest.json"))
	var audio_count: int = 0
	if audio_manifest is Dictionary and audio_manifest.get("assets") is Array:
		for asset: Dictionary in audio_manifest.assets:
			var source: String = str(asset.get("path", ""))
			var stream: AudioStream = load(source) as AudioStream
			if stream == null or stream.get_length() <= 0.0:
				_failures.append("Original audio does not load: " + source)
			else:
				audio_count += 1
	else:
		_failures.append("Export has no valid original audio manifest")
	if audio_count != 31:
		_failures.append("Original audio inventory is incomplete")
	for path: String in _paths:
		if path.ends_with(".mp3") or path.ends_with(".mp3.import") or path.ends_with(".mp3str"):
			_failures.append("Retired soundtrack in export: " + path)
		if path.ends_with(".ctex") and not allowed_textures.has(path):
			_failures.append("Unexpected raster in export: " + path)
		if path.ends_with(".png.import") and not allowed_imports.has(path):
			_failures.append("Unexpected source image in export: " + path)
		if path.ends_with(".ttf") or path.ends_with(".otf") or path.ends_with(".ttf.remap") or path.ends_with(".otf.remap"):
			_failures.append("Retired font in export: " + path)
	if allowed_imports.size() != manifest["assets"].size() or allowed_imports.is_empty():
		_failures.append("Original image inventory is incomplete")
	for failure: String in _failures:
		push_error(failure)
	print("PACK_INVENTORY=", JSON.stringify(_paths))
	print("PACK_ORIGINAL_IMAGES=", allowed_imports.size())
	print("PACK_ORIGINAL_AUDIO=", audio_count)
	print("PACK_INSPECTION_OK" if _failures.is_empty() else "PACK_INSPECTION_FAILED")
	quit(0 if _failures.is_empty() else 1)
