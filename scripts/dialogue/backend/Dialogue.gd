class_name Dialogue extends GraphElement

## Text to display in a dialogue box.
@export var text : String;

# if using dialogue icons, then need dict<name, icon>
@export var speaker : String;

@export var next_trigger : DialogueTrigger;

@export var next : GraphElement;

# TODO: implement text effects maybe here or control node?

# navigator checks type of graph element as well as its next element
# TODO: when dialogue navigator tries to get next element, should look at type of the trigger and pass the appropriate objects
func get_next(obj = null) -> GraphElement:
	if(next == null): # leaf element, no more dialogue
		return null;
		
	if(next_trigger == null): # no triggers, just return next node
		return next;
	else:
		return next if next_trigger._can_trigger(obj) else next_trigger.fail_dialogue;
