#ifdef HALLOWEEN
/datum/random_event/minor/skeletons
	weight = 50

#else
/datum/random_event/special/skeletons
#endif

	name = "Closet Skeletons"
	customization_available = 1

	admin_call(var/source)
		if (..())
			return

		var/select = input(usr, "How many skeletons to spawn (1-50)?", "Number of skeletons") as null|num

		select = max(1,select)
		select = min(50,select)

		src.event_effect(source, select)
		return

	event_effect(var/source, var/spawn_amount_selected = 0)
		..()

		var/spawn_amount = rand(7,13)
		if(spawn_amount_selected)
			spawn_amount = spawn_amount_selected

		var/list/closets = list()

		for(var/obj/storage/closet/S)
			if(istype(S,/obj/storage/secure/closet))
				if(S.loc.z == 1)
					closets += S


		var/sensortext = pick("sensors", "technicians", "probes", "satellites", "monitors")
		var/pickuptext = pick("picked up", "detected", "found", "sighted", "reported")
		var/anomlytext = pick("spooky infestation", "loud claking noise","rattling of bones")
		var/ohshittext = pick("en route for collision with", "rapidly approaching", "heading towards")
		command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] [ohshittext] the station. Be wary of closets.", "Anomaly Alert")

		spawn(1)
			for(var/i = 0, i<spawn_amount, i++)
				if(closets.len > 0)
					var/obj/storage/temp = pick(closets)
					if(temp.open)
						temp.close()
					if(temp.open)
						closets -= temp
						continue
					temp.visible_message("<span style=\"color:red\"><b>[temp]</b> emits a loud thump and rattles a bit.</span>")
					playsound(get_turf(temp), "sound/effects/bang.ogg", 50, 1)
					var/wiggle = 6
					while(wiggle > 0)
						wiggle--
						temp.pixel_x = rand(-3,3)
						temp.pixel_y = rand(-3,3)
						sleep(1)
					temp.pixel_x = 0
					temp.pixel_y = 0
					new/obj/critter/magiczombie(temp.loc)
					closets -= temp
				else
					break

