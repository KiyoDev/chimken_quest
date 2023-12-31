@tool
class_name DialogueNode extends BaseNode

signal node_updated(node : DialogueNode)

signal type_changed(type : Type)

signal play_pressed(node : DialogueNode)

signal preview_pressed(node : DialogueNode)

signal text_changed(node : DialogueNode, text : String, variables : Dictionary)


enum Type {
	DIALOGUE,
	OFFERING,
	RESPONSE
}


const NODE_TYPE = "DIALOGUE"
const VARIABLE_PATTERN := "\\${[a-zA-Z_\\.]+[\\w]*}"


@export var TypeOptions : OptionButton
@export var Speaker : LineEdit
@export var Text : TextEdit
@export var Hidden : Control

@export var OfferingsConfig : PackedScene
@export var OfferingElement : PackedScene
@export var OfferingFail : PackedScene
@export var ResponsesConfig : PackedScene
@export var ResponseElement : PackedScene

var type := Type.DIALOGUE

var offerings_config : OfferingsConfig
var item_offerings : VBoxContainer
var offering_fail : HBoxContainer
var responses_config : ResponsesConfig

var curr_resp_slots := 1
var curr_item_count := 1

var response_elements : Array[ResponseElement] = []

# TODO: highlighted variables in TextEdit must be mapped properly in order to show correctly in dialogue boxes
var variable_match := RegEx.create_from_string(VARIABLE_PATTERN)
# TODO: use set of variables when populating dialogue boxes
var dialogue_variables := {}



func _init():
	print_debug("init dialogue node")


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready")
	clean()


func _exit_tree():
	print_debug("'%s' exiting tree..." % [name])
	for child in Hidden.get_children():
		child.queue_free()


func set_type(value):
	if(value == type): return
	
	print_debug("type change - %s->%s" % [Type.keys()[type], Type.keys()[value]])
	hide_previous_options(type)
	reset_size()
	type = value
	print_debug("on type option - %s, %s" % [type, Type.keys()[value]])
	TypeOptions.select(value)
	update_node_options()
	reset_size()


func get_type():
	return type


func set_speaker(speaker : String):
	Speaker.text = speaker


func set_dialogue(text : String):
	Text.text = text


func text() -> String:
	return Text.text


func get_variables() -> Array:
	find_dialogue_variables()
	return dialogue_variables.keys()


func find_dialogue_variables():
	var found := variable_match.search_all(Text.text)
	
	dialogue_variables.clear()
	for v in found:
		var name := v.get_string()
		if(!dialogue_variables.has(name)):
			dialogue_variables[name] = true
#	if(dialogue_variables.size())
#	print_debug("dialogue - %s, vars=%s" % [Text.text, dialogue_variables])


func clean() -> DialogueNode:
	Text.syntax_highlighter = DialogueEditHighlighter.new()
	curr_resp_slots = 1
	curr_item_count = 1
	
	offerings_config = OfferingsConfig.instantiate()
	offering_fail = OfferingFail.instantiate()
	responses_config = ResponsesConfig.instantiate()
	
	add_child(offerings_config)
	add_item_offering()
	add_child(offering_fail)
	add_child(responses_config)
	add_response()
	
	on_create()
	
	return self


func on_create():
	print_debug("on_create")
	TypeOptions.clear()
	for type in Type.keys():
		TypeOptions.add_item(type, Type[type])
	type = Type.DIALOGUE
	
	response_elements.append(get_child(responses_config.get_index() + 1))
	
	offerings_config.add_offering_button.pressed.connect(_on_add_offering_pressed, CONNECT_PERSIST)
	responses_config.add_response.pressed.connect(_on_add_response_pressed, CONNECT_PERSIST)
	
	# enable all slots after adding children nodes
	for i in get_child_count():
		set_slot_enabled_right(i, true)
	
	hide_offer_slots()
	hide_response_slots()
	update_node_options()
	reset_size()


static func new_from_dict(scn : PackedScene, dict : Dictionary, graph : GraphEdit) -> DialogueNode:
	var node : DialogueNode = scn.instantiate().clean()
	node.name = dict.name.replace("@", "_")
	graph.add_child(node)
	node.set_type(DialogueNode.Type[dict.type])
	node.Speaker.text = dict.speaker
	node.Text.text = dict.text
#	print_debug("add new node=%s, %s" % [position, node])
	node.size = Vector2(dict.metadata.size.x, dict.metadata.size.y)
	var pos := Vector2(dict.metadata.position.x, dict.metadata.position.y)
	node.position_offset = pos
#	node.position_offset = Vector2(dict.metadata.position.x, dict.metadata.position.y)
	print_debug("new from dict - %s" % [dict])
	match(node.type):
		Type.DIALOGUE:
			pass
		Type.OFFERING:
			# Update node's properties to saved properties
			var index := 0
			for offering in dict.properties.offerings:
				if(index >= node.offerings_config.offering_count()):
					node.add_item_offering()
				var off : OfferingElement = node.offerings_config.get_offering(index)
				off.ItemName.text = offering.item_name
				off.ItemType.text = offering.item_type
				off.Quantity.value = offering.quantity
				index += 1
		Type.RESPONSE:
			# Update node's properties to saved properties
			var index := node.responses_config.get_index() + 1
			for response in dict.properties.responses:
				if(index >= node.get_child_count()):
					node.add_response()
				var resp : ResponseElement = node.get_child(index)
				resp.Text.text = response.text
				index += 1
		_:
			push_error("Invalid type found in dictionary - %s" % [JSON.stringify(dict, "", false)])
	return node


func from_dict(dict : Dictionary):
	name = dict.name.replace("@", "_")
	set_type(DialogueNode.Type[dict.type])
	Speaker.text = dict.speaker
	Text.text = dict.text
	size = Vector2(dict.metadata.size.x, dict.metadata.size.y)
	var pos := Vector2(dict.metadata.position.x, dict.metadata.position.y)
	position_offset = pos
	print_debug("new from dict - %s" % [dict])
#	dialogue_variables = dict.variables
	match(type):
		Type.DIALOGUE:
			pass
		Type.OFFERING:
			# Update node's properties to saved properties
			var index := 0
			for offering in dict.properties.offerings:
				if(index >= offerings_config.offering_count()):
					add_item_offering()
				var off : OfferingElement = offerings_config.get_offering(index)
				off.ItemName.text = offering.item_name
				off.ItemType.text = offering.item_type
				off.Quantity.value = offering.quantity
				index += 1
		Type.RESPONSE:
			# Update node's properties to saved properties
			var index := responses_config.get_index() + 1
			for response in dict.properties.responses:
				if(index >= get_child_count()):
					add_response()
				var resp : ResponseElement = get_child(index)
				resp.Text.text = response.text
				index += 1
		_:
			push_error("Invalid type found in dictionary - %s" % [JSON.stringify(dict, "", false)])
	find_dialogue_variables()


func get_metadata():
	return {
		"position": {"x": position_offset.x, "y": position_offset.y},
		"size": {"x": size.x, "y": size.y},
		"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
	}


func to_dict() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		"type": Type.keys()[type],
		"speaker": Speaker.text,
		"text": Text.text,
		"variables": get_variables(),
		"properties": {},
		"metadata": get_metadata()
	}
	
	match(type):
		Type.DIALOGUE:
			# TODO: add connections?
			pass
		Type.OFFERING:
			dict.properties["offerings"] = []
			for offer in offerings_config.get_offers():
				var item := {}

				item["item_name"] = offer.ItemName.text
				item["item_type"] = offer.ItemType.text
				item["quantity"] = offer.Quantity.value

				dict.properties["offerings"].append(item)
			# TODO: add connections
		Type.RESPONSE:
			# TODO: add connections but maybe is just managed by the graph editor itself
			# response index = node port for the editor connections
			dict.properties["responses"] = []
			for index in range(responses_config.get_index() + 1, get_child_count()):
				var child : ResponseElement = get_child(index)
				var response := {"text": child.text()}
				dict.properties["responses"].append(response)
#			print_debug("responses - %s" % [get_responses()])
			pass
	return dict


func to_dict_no_meta() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		"type": Type.keys()[type],
		"speaker": Speaker.text,
		"text": Text.text,
		"variables": get_variables(),
		"properties": {}
	}
	
	match(type):
		Type.DIALOGUE:
			# TODO: add connections?
			pass
		Type.OFFERING:
			dict.properties["offerings"] = []
			for offer in offerings_config.get_offers():
				var item := {}

				item["item_name"] = offer.ItemName.text
				item["item_type"] = offer.ItemType.text
				item["quantity"] = offer.Quantity.value

				dict.properties["offerings"].append(item)
			# TODO: add connections
		Type.RESPONSE:
			# TODO: add connections but maybe is just managed by the graph editor itself
			# response index = node port for the editor connections
			dict.properties["responses"] = []
			for index in range(responses_config.get_index() + 1, get_child_count()):
				var child : ResponseElement = get_child(index)
				var response := {"text": child.text()}
				dict.properties["responses"].append(response)
#			print_debug("responses - %s" % [get_responses()])
			pass
	return dict


func update_node_options():
	match(type):
		Type.DIALOGUE:
			set_slot_enabled_right(0, true)
		Type.OFFERING:
			offerings_config.reparent(self)
			offering_fail.reparent(self)
			offerings_config.show()
			offering_fail.show()
			print_debug("g - %s, %s" % [offerings_config.get_index(), offering_fail.get_index()])
			set_slot_enabled_right(offerings_config.get_index(), true)
			set_slot_enabled_right(offering_fail.get_index(), true)
		Type.RESPONSE:
			responses_config.reparent(self)
			responses_config.show()
			set_slot_enabled_right(responses_config.get_index(), false) # config index = first response slot
			print_debug("switching to  resp - [%s, %s]" % [get_connection_output_count(), response_elements])
			var index := 0
			for child in response_elements:
				child.reparent(self)
				child.show()
				set_slot_enabled_right(index + responses_config.get_index() + 1, true)
				print_debug("resp - child[%s]=%s" % [index, child])
#	print_debug("slo - count=%s, curr=%s" % [get_connection_output_count(), curr_resp_slots])
	reset_size()


func hide_previous_options(type : Type):
	match(type):
		Type.DIALOGUE:
			set_slot_enabled_right(0, false)
			slots_removed.emit(self, 0)
		Type.OFFERING:
			hide_offer_slots()
		Type.RESPONSE:
			hide_response_slots()


func hide_offer_slots():
	if(!offerings_config.visible || !offering_fail.visible): return
	
	print_debug("hiding offer - [%s]" % [get_connection_output_count()])
	print_debug("hiding - [%s, %s]" % [get_connection_output_slot(0), get_connection_output_slot(1)])

	offerings_config.reparent(Hidden)
	offering_fail.reparent(Hidden)
	offerings_config.hide()
	offering_fail.hide()
	slots_removed.emit(self, 0)
	slots_removed.emit(self, 1)


func hide_response_slots():
	if(!responses_config.visible): return
	for index in range(get_child_count() - 1, responses_config.get_index(), -1):
		var child := get_child(index)
		print_debug("hiding resp[%s, %s]=%s" % [index - responses_config.get_index() + 1, is_slot_enabled_right(index - responses_config.get_index() + 1), child])
		print_debug("%s, %s" % [is_slot_enabled_right(0), is_slot_enabled_right(1)])
#		set_slot_enabled_right(index - responses_config.get_index() + 1, false)
		child.reparent(Hidden)
		child.hide()
		slots_removed.emit(self, index - (responses_config.get_index() + 1))
	responses_config.reparent(Hidden)
	responses_config.hide()


func add_response():
	curr_resp_slots += 1
#	print_debug("5 - %s=%s" % [curr_last_index + i, is_slot_enabled_right(curr_last_index + i)])
#	print_debug("value > curr [count=%s, i=%s, last=%s, slot_config=%s, rsp=%s]" % [get_child_count(), i, curr_last_index, responses_config.get_index(), response_elements])
	var new_resp = ResponseElement.instantiate()
	response_elements.append(new_resp)
	new_resp.delete_requested.connect(_on_delete_response, CONNECT_PERSIST)
	add_child(new_resp)
	set_slot_enabled_right(curr_resp_slots + responses_config.get_index() + 1, true)


func delete_response(response : ResponseElement):
	slots_removed.emit(self, response.get_index() - 2)
	response.queue_free()
	response_elements.erase(response)
	curr_resp_slots -= 1


func add_item_offering():
	curr_item_count += 1
	var new_offering := OfferingElement.instantiate()
	new_offering.delete_requested.connect(_on_delete_offering, CONNECT_PERSIST)
	offerings_config.add_offering(new_offering)


func delete_item_offering(offering : OfferingElement):
	curr_item_count -= 1
	offerings_config.remove_offering(offering)


func empty() -> DialogueNode:
	var node := super.duplicate(0b0111)
	node.type = Type.DIALOGUE
	print_debug("empty - %s" % [node.dialogue])
	return node


func get_responses() -> Array[ResponseElement]:
	var responses : Array[ResponseElement] = []
	
	for i in range(responses_config.get_index() + 1, get_child_count()):
		var resp = get_child(i)
#		print_debug("a - %s" % resp)
		responses.append(resp)
	
	return responses


func close_node():
	queue_free()


func to_string_pretty() -> String:
	return JSON.stringify(to_dict(), "\t", false)


func _to_string():
	return JSON.stringify(to_dict(), "", false)


#region Signal Callbacks

func _on_speaker_text_changed(new_text):
	print_debug("speaker - %s" % [Speaker.text])
	node_updated.emit(self)


func _on_dialogue_text_changed():
	find_dialogue_variables()
	text_changed.emit(self, Text.text, dialogue_variables)
	node_updated.emit(self)


func _on_test_print_pressed():
	print_debug("%s={type: %s,%s: '%s'}" % [name, type, Speaker.text, Text.text])


func _on_type_options_item_selected(index):
#	var key = Type.keys()[index]
#	print_debug("on type option - %s" % [Type.get(key)])
	print_debug("type change - %s->%s" % [Type.keys()[type], Type.keys()[index]])
	hide_previous_options(type)
	reset_size()
	type = index
	print_debug("on type option - %s, %s" % [type, Type.keys()[index]])
	TypeOptions.select(index)
	update_node_options()
	reset_size()
	node_updated.emit(self)


func _on_add_offering_pressed():
	print_debug("on add offering")
	add_item_offering()
	reset_size()
	node_updated.emit(self)


func _on_delete_offering(offering : OfferingElement):
	print_debug("on delete offering")
	delete_item_offering(offering)
	reset_size()
	node_updated.emit(self)


func _on_add_response_pressed():
	print_debug("on add response")
	add_response()
	reset_size()
	node_updated.emit(self)
	
	
func _on_delete_response(response : ResponseElement):
	print_debug("on delete response - %s" % [response])
	delete_response(response)
	reset_size()
	node_updated.emit(self)


func _on_preview_pressed():
	print_debug("on '%s' preview" % [name])
	preview_pressed.emit(self)


func _on_play_pressed():
	print_debug("Play dialogue")
	play_pressed.emit(self)
