extends TextForgeMode
# Officail Text Forge mode template.
# MIT Licensed

# Template usage check-list:
# - [ ] Initializing
#     - [ ] Rename mode folder
#     - [ ] Edit mode information file
#     - [ ] Add mode icon
# - [ ] Roles
#     - [ ] Define keywords
#     - [ ] Define code regions
#     - [ ] Define delimiters
# - [ ] Encoding system
#     - [ ] Define encoder or remove it
#     - [ ] Define decoder or remove it
# - [ ] Optional features
#     - [ ] Define panel or remove it
#     - [ ] Handle auto format feature or remove it
#         - [ ] Uncomment _enable_auto_format_feature() or remove it
#         - [ ] Complete _auto_format() or remove it
#     - [ ] Handle auto indent feature or remove it
#         - [ ] Uncomment _enable_auto_indent_feature() or remove it
#         - [ ] Complete _auto_indent() or remove it
#     - [ ] Add code completion or remove it
#     - [ ] Add preview generation or remove it
#     - [ ] Add outline generation or remove it
#     - [ ] Add linting or remove it
# - [ ] Text & Cleanup
#     - [ ] Test mode
#     - [ ] Remove any virtual function if it's same as default function
#     - [ ] Remove unnecessary comments, section and region guides
# - [ ] Share it with "text-forge" tag🚀

# --- PROPERTIES ---

# Use example to add keywords with colors.
# Pattern:
# Color(r, g, b, a) : ["keyword1", "keyword2", ...]
var keyword_colors: Dictionary[Color, Array] = {
	Color(1, 0.2, 0.2, 1): ["some", "example"],
	Color(1, 0.55, 0.8, 1): ["keyword", "for you"],
}
# Use example to add code regions with color.
# Pattern:
# [Color(r, g, b, a), "start_key", "end_key", line_only]
var code_regions: Array[Array] = [
	[Color(1, 0.92, 0.64, 1), '"', '"', false],
	[Color(1, 0.92, 0.64, 1), "'", "'", false],
	[Color(0.8, 0.81, 0.82, 0.5), "#", "", true],
]

# --- VIRTUAL METHODS ---

# Use this method to initialize mode and set properties.
func _initialize_mode() -> Error:
	# Initializing highlighter
	_initialize_highlighter()
	# Add comment and string delimiters (optional)
	_initialize_delimiters()
	# Initializing panel (optional)
	_initialize_panel()
	# Initializing features (remove # for each feature you want)
	#_enable_auto_format_feature() # use _auto_format() to handle
	#_enable_auto_indent_feature() # use _auto_indent() to handle
	return OK

#region save / load

# This region contains save and load features. You should have a encode logic and a decode logic in
# reverse direction. If your mode uses UTF-8 for encode / decode files, you can remove these 
# functions, UTF-8 is default encoding.

# Use this method to handle convert String (in editor) to PackedByteArray (for files),
# this is file saving section of your mode.
func _string_to_buffer(string: String) -> PackedByteArray:
	return string.to_utf8_buffer()


# Use this method to load a PackedByteArray (stored in a file) to String (for editor),
# this is file loading section of your mode.
func _buffer_to_string(buffer: PackedByteArray) -> String:
	return buffer.get_string_from_utf8()

#endregion

# Use this method to handle optional code completion feature, text argument is the full editor text 
# with char 0xFFFF at the caret location. Use Global.get_editor().add_code_completion_option() for 
# this task.
# This feature is optional, so you can remove this function.
func _update_code_completion_options(text: String) -> void:
	pass


# Use this method to handle preview feature, text argument is the full editor text and this
# method should return preview as string. (you can use BBCode for formatting)
# This feature is optional, so you can remove this function.
func _generate_preview(text: String) -> String:
	return String()


# Use this method to handle outline feature, text argument is the full editor text and this
# method should return a nested array as table of content / symbols in this strcuture:
# [ # Highest array is root of file, don't add text and line number here
#     [
#         "Heading 1", # text of current section
#         0, # line of section from 0
#         [ # define optional sub-sections as arrays after text and line number
#             "Heading 2 (1)",
#             10,
#         ],
#         [ # another sub-section
#             "Heading 2 (2)",
#             14,
#             [ # each section can have zero or more sub-sections
#                 "Heading 3",
#                 16,
#             ],
#         ],
#     ],
# ]
# Above structure is for a file like this (markdown example):
# # Heading 1
# ...
# ## Heading 2 (1)
# ...
# ## Heading 2 (2)
# ...
# ### Heading 3
# ...
# And will be shown as:
# Heading 1/
#     Heading 2 (1)
#     Heading 2 (2)/
#         Heading 3
# Highest array is root of file, this array allows you to have more than one first-class section.
# This feature is optional, so you can remove this function.
func _generate_outline(text: String) -> Array:
	return Array()


# Use this method to handle linting, text argument is the full editor text and this method
# should return an array of problems in this strcuture:
# {
#     "line": int, # from 0
#     "column": int, # from 0, -1 for all of line
#     "error": bool, # false for warnings, true for errors
#     "title": String,
#     "details": String,
# }
# This feature is optional, so you can remove this function.
func _lint_file(text: String) -> Array[Dictionary]:
	return Array([], TYPE_DICTIONARY, "", null)


# Use this method to add auto format feature.
# This feature is optional, so:
# if your mode supports it:
# 		- Uncomment _enable_auto_format_feature() in _initialize_mode()
# 		- Add auto fomrat logic in this function, text is current file content and this function should return formatted content
# otherwise:
#		- Remove #_enable_auto_format_feature() in _initialize_mode() (optional)
# 		- Remove this function
func _auto_format(text: String) -> String:
	return text


# Use this method to add auto indent feature.
# This feature is optional, so:
# if your mode supports it:
# 		- Uncomment _enable_auto_indent_feature() in _initialize_mode()
# 		- Add auto indent logic in this function, text is current file content and this function should return content with automatic indention
# otherwise:
#		- Remove #_enable_auto_indent_feature() in _initialize_mode() (optional)
# 		- Remove this function
func _auto_indent(text: String) -> String:
	return text

# --- INTENRAL FUNCTIONS ---

func _initialize_highlighter() -> void:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.number_color = Color(0.63, 1, 0.88, 1)
	syntax_highlighter.symbol_color = Color(0.67, 0.79, 1, 1)
	syntax_highlighter.function_color = Color(0.35, 0.7, 1, 1)
	syntax_highlighter.member_variable_color = Color(0.73, 0.87, 1, 1)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)
	
	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])


func _initialize_delimiters() -> void:
	comment_delimiters.append({
		"start_key": "#",
		"end_key": "",
		"line_only": true,
	})
	string_delimiters.append({
		"start_key": '"',
		"end_key": '"',
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "'",
		"end_key": "'",
		"line_only": false,
	})


func _initialize_panel() -> void:
	panel = TextForgePanel.new()
	panel.custom_minimum_size = Vector2(200, 0)
	panel.add_child(Label.new())
	panel.get_child(0).text = "Template Mode"

