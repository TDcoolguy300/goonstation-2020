/*
CONTAINS:
TOILET
*/
var/list/all_toilets = null

/obj/item/storage/toilet
	name = "toilet"
	w_class = 4.0
	anchored = 1.0
	density = 0.0
	mats = 5
	var/status = 0.0
	var/clogged = 0.0
	anchored = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	rand_pos = 0

/obj/item/storage/toilet/New()
	..()
	if (!islist(all_toilets))
		all_toilets = list()
	all_toilets.Add(src)

/obj/item/storage/toilet/disposing()
	if (islist(all_toilets))
		all_toilets.Remove(src)
	..()

/obj/item/storage/toilet/attackby(obj/item/W as obj, mob/user as mob)
	if (src.contents.len >= 7)
		boutput(user, "The toilet is clogged!")
		return
	if (istype(W, /obj/item/storage))
		return
	if (istype(W, /obj/item/grab))
		playsound(get_turf(src), "sound/effects/toilet_flush.ogg", 50, 1)
		user.visible_message("<span style='color:blue'>[user] gives [W:affecting] a swirlie!</span>", "<span style='color:blue'>You give [W:affecting] a swirlie. It's like Middle School all over again!</span>")
		return

	return ..()

/obj/item/storage/toilet/MouseDrop(atom/over_object, src_location, over_location)
	if (usr && over_object == usr && in_range(src, usr) && iscarbon(usr) && !usr.stat)
		usr.visible_message("<span style='color:red'>[usr] [pick("shoves", "sticks", "stuffs")] [his_or_her(usr)] hand into [src]!</span>")
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
	..()

/obj/item/storage/toilet/MouseDrop_T(mob/living/carbon/human/M as mob, mob/user as mob) // Yeah, uh, only living humans should use the toilet
	if (!ticker)
		boutput(user, "You can't help relieve anyone before the game starts.")
		return
	if (!ishuman(M) || get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || user.stat)
		return
	if (M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/mario) && istype(H.head, /obj/item/clothing/head/mario))
			user.visible_message("<span style='color:blue'>[user] dives into [src]!</span>", "<span style='color:blue'>You dive into [src]!</span>")
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(src.loc))
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)

			var/list/destinations = list()

			if (islist(all_toilets) && all_toilets.len)
				for (var/obj/item/storage/toilet/T in all_toilets)
					if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z))
						continue
					destinations.Add(T)
			else
				destinations.Add(src)

			if (destinations.len)
				var/atom/picked = pick(destinations)
				particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(picked.loc))
				M.set_loc(picked.loc)
				playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
				user.visible_message("<span style='color:blue'>[user] emerges from [src]!</span>", "<span style='color:blue'>You emerge from [src]!</span>")
			return

	if (M == user)
		user.visible_message("<span style='color:blue'>[user] sits on [src].</span>", "<span style='color:blue'>You sit on [src].</span>")
	else
		user.visible_message("<span style='color:blue'>[M] is seated on [src] by [user]!</span>")
	M.anchored = 1
	M.buckled = src
	M.set_loc(src.loc)
	src.add_fingerprint(user)
	return

/obj/item/storage/toilet/attack_hand(mob/user as mob)
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message("<span style='color:blue'>[M] is zipped up by [user]. That's... that's honestly pretty creepy.</span>")
			else
				user.visible_message("<span style='color:blue'>[M] zips up.</span>", "<span style='color:blue'>You zip up.</span>")
//			boutput(world, "[M] is no longer buckled to [src]")
			M.anchored = 0
			M.buckled = null
			src.add_fingerprint(user)
	if((src.clogged < 1) || (src.contents.len < 7) || (user.loc != src.loc))
		user.visible_message("<span style='color:blue'>[user] flushes [src].</span>", "<span style='color:blue'>You flush [src].</span>")
		playsound(get_turf(src), "sound/effects/toilet_flush.ogg", 50, 1)


#ifdef UNDERWATER_MAP
		if (isturf(src.loc))
			var/turf/target = locate(src.x,src.y,5)
			for (var/thing in contents)
				var/atom/movable/A = thing
				A.set_loc(target)
#endif
		src.clogged = 0
		src.contents.len = 0

	else if((src.clogged >= 1) || (src.contents.len >= 7) || (user.buckled != src.loc))
		src.visible_message("<span style='color:blue'>The toilet is clogged!</span>")

/obj/item/storage/toilet/custom_suicide = 1
/obj/item/storage/toilet/suicide_in_hand = 0
/obj/item/storage/toilet/suicide(var/mob/living/carbon/human/user as mob)
	if (!ishuman(user) || !user.organHolder)
		return 0

	user.visible_message("<span style='color:red'><b>[user] sticks [his_or_her(user)] head into [src] and flushes it, giving [him_or_her(user)]self an atomic swirlie!</b></span>")
	var/obj/head = user.organHolder.drop_organ("head")
	if (src.clogged >= 1 || src.contents.len >= 7 || !(islist(all_toilets) && all_toilets.len))
		head.set_loc(src.loc)
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
		src.visible_message("<span style='color:blue'>[head] floats up out of the clogged [src.name]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span style='color:red'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span style='color:red'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()
	else
		var/list/emergeplaces = list()
		for (var/obj/item/storage/toilet/T in all_toilets)
			if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
			emergeplaces.Add(T)
		if (emergeplaces.len)
			var/atom/picked = pick(emergeplaces)
			head.set_loc(picked.loc)
			playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
			head.visible_message("<span style='color:blue'>[head] emerges from [picked]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span style='color:red'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span style='color:red'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()

	playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
	user.updatehealth()
	SPAWN_DBG(100)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/storage/toilet/random
	New()
		..()
		if (prob(1))
			var/something = pick(trinket_safelist)
			if (ispath(something))
				new something(src)

/obj/item/storage/toilet/random/gold // important!!
	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/storage/toilet/random/escapetools
	spawn_contents = list(/obj/item/wirecutters,\
	/obj/item/screwdriver,\
	/obj/item/wrench,\
	/obj/item/crowbar,)

/obj/item/storage/toilet/goldentoilet
	name = "golden toilet"
	icon_state = "goldentoilet"
	desc = "The result of years of stolen Nanotrasen funds."

	New()
		..()
		particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(src))