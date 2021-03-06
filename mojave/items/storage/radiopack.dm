/obj/item/ms13/storage/backpack/radiopack
	icon = 'mojave/icons/objects/clothing/backpack.dmi'
	name = "radiopack"
	icon_state = "radiopack"
	worn_icon = 'mojave/icons/mob/clothing/back.dmi'
	lefthand_file = 'mojave/icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'mojave/icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "radiopack"
	desc = "A basic handheld radio that communicates over a relatively long range, and is proven to be 254% better than yelling loudly."
	slot_flags = ITEM_SLOT_BACK
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=75, /datum/material/glass=25)
	var/held = 0
	var/obj/item/radio/ms13/NCR/radio

/obj/item/ms13/storage/backpack/radiopack/Initialize()
	. = ..()
	radio = new(src)
	START_PROCESSING(SSobj, src)
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 18
	STR.max_items = 5

/obj/item/ms13/storage/backpack/radiopack/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/ms13/storage/backpack/radiopack/AltClick(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!held)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				held = 1
				if(!user.put_in_hands(radio))
					held = 0
					to_chat(user, "<span class='warning'>You need a free hand to hold the radio!</span>")
					return
				update_icon()
				user.update_inv_back()
		else
			to_chat(user, "<span class='warning'>You are already holding the radio!</span>")
	else
		..()

/obj/item/ms13/storage/backpack/radiopack/attackby(obj/item/W, mob/user, params)
	if(W == radio)
		user.dropItemToGround(radio, TRUE)
	else
		..()

/obj/item/ms13/storage/backpack/radiopack/dropped(mob/user)
	. = ..()
	if(held)
		user.dropItemToGround(radio, TRUE)

/obj/item/ms13/storage/backpack/radiopack/MouseDrop(atom/over_object)
	. = ..()
	if(held)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.incapacitated())

			if(istype(over_object, /atom/movable/screen/inventory/hand))
				var/atom/movable/screen/inventory/hand/H = over_object
				M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/ms13/storage/backpack/radiopack/proc/attach_radio(var/mob/user)
	if(!radio)
		radio = new(src)
	radio.forceMove(src)
	held = 0
	if(user)
		to_chat(user, "<span class='notice'>You attach the [radio.name] to the [name].</span>")
	else
		src.visible_message("<span class='warning'>The [radio.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()

/obj/item/radio/ms13
	icon = 'mojave/icons/objects/hamradio.dmi'
	name = "walkie-talkie"
	icon_state = "handradio"
	inhand_icon_state = "handradio_"
	desc = "A basic handheld radio that communicates over a relatively long range, and is proven to be 254% better than yelling loudly."
	dog_fashion = /datum/dog_fashion/back

	flags_1 = CONDUCT_1 | HEAR_1
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=75, /datum/material/glass=25)
	obj_flags = USES_TGUI

/obj/item/radio/ms13/NCR
	obj_flags = USES_TGUI
	broadcasting = TRUE
	freerange = TRUE
	frequency = 1359
	keyslot = new /obj/item/encryptionkey/headset_sec
	subspace_transmission = TRUE
	var/obj/item/ms13/storage/backpack/radiopack/radiopack
	var/req_radio = TRUE

/obj/item/radio/can_receive(freq, level, AIuser)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.is_holding(src))
			return ..(freq, level)
	else if(AIuser)
		return ..(freq, level)
	return FALSE

/obj/item/radio/ms13/NCR/Initialize()
	if(istype(loc, /obj/item/ms13/storage/backpack/radiopack))
		radiopack = loc

	else
		return INITIALIZE_HINT_QDEL

	return ..()

/obj/item/radio/ms13/NCR/attack_self(mob/living/user)
	return

/obj/item/radio/ms13/NCR/dropped(mob/user)
	. = ..()
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	if(req_radio)
		if(user)
			to_chat(user, "<span class='notice'>The walkie talkie snaps back into place on the radiopack.</span>")
		snap_back()

/obj/item/radio/ms13/NCR/proc/snap_back()
	if(!radiopack)
		return
	forceMove(radiopack)

/obj/item/radio/ms13/NCR/doMove(atom/destination)
	if(destination && (destination != radiopack.loc || !ismob(destination)))
		if (loc != radiopack)
			to_chat(radiopack.loc, "<span class='notice'>The walkie talkie snaps back into place on the radiopack.</span>")
		destination = radiopack
	..()
