@tool
class_name OfferingsConfig extends VBoxContainer


@export var Offerings : VBoxContainer;
@export var ItemCount : SpinBox;


func set_item_count(value : int):
	ItemCount.value = value;


func get_offers() -> Array[OfferingElement]:
	var offerings : Array[OfferingElement] = [];
	
	for offering in Offerings.get_children():
		offerings.append(offering);
	
	return offerings;
