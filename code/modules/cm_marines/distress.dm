//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.



/proc/spawn_merc_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/merc_sidearms = list(
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
		/obj/item/weapon/gun/pistol/m1911 = /obj/item/ammo_magazine/pistol/m1911,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
		/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended)

	var/list/merc_firearms = list(
		/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/combat = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/m41aMK1 = /obj/item/ammo_magazine/rifle/m41aMK1,
		/obj/item/weapon/gun/smg/p90 = /obj/item/ammo_magazine/smg/p90)

	var/gunpath = sidearm? pick(merc_sidearms) : pick(merc_firearms)
	var/ammopath = sidearm? merc_sidearms[gunpath] : merc_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/weapon/storage))
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1

/proc/spawn_slavic_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/rus_sidearms = list(
		/obj/item/weapon/gun/revolver/upp = /obj/item/ammo_magazine/revolver/upp,
		/obj/item/weapon/gun/revolver/mateba = /obj/item/ammo_magazine/revolver/mateba,
		/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/c99/russian = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended)

	var/list/rus_firearms = list(/obj/item/weapon/gun/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40/extended,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended,
		/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/rifle/sniper/svd)

	var/gunpath = sidearm? pick(rus_sidearms) : pick(rus_firearms)
	var/ammopath = sidearm? rus_sidearms[gunpath] : rus_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/weapon/storage))
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1

//basic persistent gamemode stuff.
/datum/game_mode
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/has_called_emergency = 0
	var/distress_cooldown = 0
	var/waiting_for_candidates = 0

//The distress call parent. Cannot be called itself due to "name" being a filtered target.
/datum/emergency_call
	var/name = "name"
	var/mob_max = 0
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Msg to display when starting
	var/arrival_message = "" //Msg to display about when the shuttle arrives
	var/objectives //Txt of objectives to display to joined. Todo: make this into objective notes
	var/probability = 0 //Chance of it occuring. Total must equal 100%
	var/hostility //For ERTs who are either hostile or friendly by random chance.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
//	var/waiting_for_candidates = 0 //Are we waiting on people to join?
	var/role_needed = BE_RESPONDER //Obsolete
	var/name_of_spawn = "Distress" //If we want to set up different spawn locations
	var/mob/living/carbon/leader = null //Who's leading these miscreants

//Weyland Yutani commandos. Friendly to USCM, hostile to xenos.
/datum/emergency_call/pmc
	name = "Weyland-Yutani PMC"
	mob_max = 6
	probability = 30

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USCSS Royce responding to your distress call. We are boarding. Any hostile actions will be met with lethal force."
		objectives = "Secure the Corporate Liaison and the [MAIN_SHIP_NAME] Commander, and eliminate any hostile threats. Do not damage W-Y property."

//Supply drop. Just docks and has a crapload of stuff inside.
/datum/emergency_call/supplies
	name = "Supply Drop"
	mob_max = 0
	arrival_message = "Weyland Yutani Automated Supply Drop 334-Q signal received. Docking procedures have commenced."
	probability = 5

//Randomly-equipped mercenaries. May be friendly or hostile to the USCM, hostile to xenos.
/datum/emergency_call/mercs
	name = "Mercenaries"
	mob_max = 5
	probability = 30

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is mercenary vessel MC-98 responding to your distress call. Prepare for boarding."
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

//Xenomorphs, hostile to everyone.
/datum/emergency_call/xenos
	name = "Xenomorphs"
	mob_max = 6
	probability = 30
	role_needed = BE_ALIEN

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USS Vriess respond-- #&...*#&^#.. signal.. oh god, they're in the vent---... Priority Warning: Signal lost."
		objectives = "For the Empress!"

//Russian 'iron bear' mercenaries. Hostile to everyone. //TODO Replace.
/datum/emergency_call/bears
	name = "Iron Bears"
	mob_max = 5
	probability = 0

	New()
		..()
		arrival_message = "Incoming Transmission: ' Vrageskie korabli pryamo po kursu, podgotovitcya k shturmu, ekipaj lekvidirovat!'"
		objectives = "Kill everything that moves. Blow up everything that doesn't. Listen to your superior officers and take over the [MAIN_SHIP_NAME] at all costs."

//Terrified pizza delivery
/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 1
	arrival_message = "Incoming Transmission: 'That'll be.. sixteen orders of cheesy fries, eight large double topping pizzas, nine bottles of Four Loko.. hello? Is anyone on this ship? Your pizzas are getting cold.'"
	objectives = "Make sure you get a tip!"
	probability = 5

//Blank colonist ERT for admin stuff.
/datum/emergency_call/colonist
	name = "Colonists"
	mob_max = 8
	arrival_message = "Incoming Transmission: 'This is the *static*. We are *static*.'"
	objectives = "Follow the orders given to you."
	probability = 0

//Dutch's Dozen. Friendly to the USCM, but more neutral than anything. //TODO Replace.
/datum/emergency_call/dutch
	name = "Dutch's Team"
	mob_max = 5
	arrival_message = "Incoming Transmission: 'Get to the shuttle! This is Major Dutch and my team of mercenaries. Responding to your distress call.'"
	objectives = "Follow the orders of Dutch and assist the marines. If there are any Yajuta on the field, you are to give it your full attention. If the shuttle is called, you need to get to it."
	probability = 0

//Deathsquad Commandos
/datum/emergency_call/death
	name = "Weyland Deathsquad"
	mob_max = 5
	arrival_message = "Intercepted Transmission: '!`2*%slau#*jer t*h$em a!l%. le&*ve n(o^ w&*nes%6es.*v$e %#d ou^'"
	objectives = "Wipe out everything. Ensure there are no traces of the infestation or any witnesses."
	probability = 0



/*
/datum/emergency_call/xenoborgs
	name = "Xenoborgs"
	mob_max = 2
	arrival_message = "Incoming Transmission: 'Under Weyland-Yutani Contract order 88-19 subset 3.4, we have dispatched a squad of research prototypes to your location. Please stand by for boarding.'"
	objectives = "Do whatever Weyland Yutani needs you to do."
	probability = 0
*/
/datum/game_mode/proc/initialize_emergency_calls()
	if(all_calls.len) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!total_calls.len)
		world << "\red \b Error setting up emergency calls, no datums found."
		return 0
	for(var/S in total_calls)
		var/datum/emergency_call/C= new S()
		if(!C)	continue
		if(C.name == "name") continue //The default parent, don't add it
		all_calls += C

//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/chance = rand(1,100)
	var/add_prob = 0
	var/datum/emergency_call/chosen_call

	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(chance >= E.probability + add_prob) //Tally up probabilities till we find which one we landed on
			add_prob += E.probability
			continue
		chosen_call = E //Our random chance found one.
		E.hostility = pick(0,1)
		break

	if(!istype(chosen_call))
		world << "\red Something went wrong with emergency calls. Tell a coder!"
		return null
	else
		return chosen_call

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !ticker || !ticker.mode) //Just a supply drop, don't bother.
		return

//	var/list/datum/mind/possible_joiners = ticker.mode.get_players_for_role(role_needed) //Default role_needed is BE_RESPONDER
	for(var/mob/dead/observer/M in player_list)
		if(M.client)
			M << "<font size='3'><span class='attack'>An emergency beacon has been activated. Use the <B>Join Response Team</b> verb, <B>IC tab</b>, to join!</span>"
			M << "<span class='attack'>You cannot join if you have been ghosted for less than a few minutes.</span>"

/datum/game_mode/proc/activate_distress()
	picked_call = get_random_call()
	if(!istype(picked_call, /datum/emergency_call)) //Something went horribly wrong
		return
	if(ticker && ticker.mode && ticker.mode.waiting_for_candidates) //It's already been activated
		return
	picked_call.activate()
	return

/client/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "IC"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	if(istype(usr,/mob/dead) || istype(usr,/mob/new_player))
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Military Police"))
			usr << "<span class='danger'>You are jobbanned from the emergency reponse team!</span>"
			return
		if(!ticker || !ticker.mode || isnull(ticker.mode.picked_call))
			usr << "<span class='warning'>No distress beacons are active. You will be notified if this changes.</span>"
			return

		var/datum/emergency_call/distress = ticker.mode.picked_call //Just to simplify things a bit
		if(!istype(distress) || !distress.mob_max)
			usr << "<span class='warning'>The emergency response team is already full!</span>"
			return
		var/deathtime = world.time - usr.timeofdeath

		if(deathtime < 600) //Nice try, ghosting right after the announcement
			usr << "<span class='warning'>You ghosted too recently.</span>"
			return

		if(!ticker.mode.waiting_for_candidates)
			usr << "<span class='warning'>The emergency response team has already been selected.</span>"
			return

		if(!usr.mind) //How? Give them a new one anyway.
			usr.mind = new /datum/mind(usr.key)
			usr.mind.active = 1
			usr.mind.current = usr
		if(usr.mind.key != usr.key) usr.mind.key = usr.key //Sigh. This can happen when admin-switching people into afking people, leading to runtime errors for a clientless key.

		if(!usr.client || !usr.mind) return //Somehow
		if(usr.mind in distress.candidates)
			usr << "<span class='warning'>You are already a candidate for this emergency response team.</span>"
			return

		if(distress.add_candidate(usr))
			usr << "<span class='boldnotice'>You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team.</span>"
		else
			usr << "<span class='warning'>You did not get enlisted in the response team. Better luck next time!</span>"
		return
	else
		usr << "<span class='warning'>You need to be an observer or new player to use this.</span>"
	return

/datum/emergency_call/proc/activate(var/announce = 1)
	if(!ticker || !ticker.mode) //Something horribly wrong with the gamemode ticker
		return

	if(ticker.mode.has_called_emergency) //It's already been called.
		return

	if(mob_max > 0)
		ticker.mode.waiting_for_candidates = 1
	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.", 1)

	if (announce)
		command_announcement.Announce("A distress beacon has been launched from the [MAIN_SHIP_NAME].", "Priority Alert")

	ticker.mode.has_called_emergency = 1
	spawn(600) //If after 60 seconds we aren't full, abort
		if(candidates.len < mob_max)
			message_admins("Aborting distress beacon, not enough candidates: found [candidates.len].", 1)
			ticker.mode.waiting_for_candidates = 0
			ticker.mode.has_called_emergency = 0
			members = list() //Empty the members list.
			candidates = list()

			if (announce)
				command_announcement.Announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

			ticker.mode.distress_cooldown = 1
			ticker.mode.picked_call = null
			spawn(1200)
				ticker.mode.distress_cooldown = 0
		else //We've got enough!
			//Trim down the list
			var/list/datum/mind/picked_candidates = list()
			if(mob_max > 0)
				for(var/i = 1 to mob_max)
					if(!candidates.len) break//We ran out of candidates, maybe they alienized. Use what we have.
					var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
					if(istype(M.current,/mob/living/carbon/Xenomorph))
						candidates.Remove(M) //Strip them from the list, they aren't dead anymore.
						if(!candidates.len) break //NO picking from empty lists
						M = pick(candidates)
					if(!istype(M))//Something went horrifically wrong
						candidates.Remove(M)
						if(!candidates.len) break //No empty lists!!
						M = pick(candidates) //Lets try this again
					picked_candidates.Add(M)
					candidates.Remove(M)
				spawn(3) //Wait for all the above to be done
					if(candidates.len)
						for(var/datum/mind/I in candidates)
							if(I.current)
								I.current << "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>"

			if (announce)
				command_announcement.Announce(dispatch_message, "Distress Beacon") //Announcement that the Distress Beacon has been answered, does not hint towards the chosen ERT

			message_admins("Distress beacon: [src.name] finalized, setting up candidates.", 1)
			var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles["Distress"]
			if(!shuttle || !istype(shuttle))
				message_admins("Warning: Distress shuttle not found. Aborting.")
				return
			sleep(1)
			spawn_items()
			sleep(1)
			shuttle.launch()
			if(picked_candidates.len)
				var/i = 0
				for(var/datum/mind/M in picked_candidates)
					members += M
					i++
					if(i > 10) break //Some logic. Hopefully this will never happen..
					spawn(1 + i)
						create_member(M)
			candidates = null //Blank out the candidates list for next time.
			candidates = list()
			/*
			 * Commented because we can't have nice things
			spawn(1100) //After 100 seconds, send the arrival message. Should be about the right time they make it there.
				command_announcement.Announce(arrival_message, "Docked")
			 */

			spawn(5200)
				shuttle.launch() //Get that fucker back. TODO: Check for occupants.

/datum/emergency_call/proc/add_candidate(var/mob/M)
	if(!M.client) return 0//Not connected
	if(M.mind && M.mind in candidates) return 0//Already there.
	if(istype(M,/mob/living/carbon/Xenomorph) && !M.stat) return 0//Something went wrong
	if(M.mind)
		candidates += M.mind
	else
		if(M.key)
			M.mind = new /datum/mind(M.key)
			candidates += M.mind
	return 1

/datum/emergency_call/proc/get_spawn_point(var/is_for_items = 0)
	var/list/spawn_list = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(is_for_items && L.name == "[name_of_spawn]Item")
			spawn_list += L
		else
			if(L.name == name_of_spawn) //Default is "Distress"
				spawn_list += L

	if(!spawn_list.len) //Empty list somehow
		return null

	var/turf/spawn_loc	= get_turf(pick(spawn_list))
	if(!istype(spawn_loc))
		return null

	return spawn_loc


/datum/emergency_call/proc/create_member(var/datum/mind/M) //This is the parent, each type spawns its own variety.
	return

/datum/emergency_call/pmc/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "PMC [pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "PMC [pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)

	mob.key = M.key
//	M.transfer_to(mob)


	mob.mind.assigned_role = "PMC"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob.mind.special_role = "MODE"
			mob.mind.assigned_role = "PMC Leader"
			mob << "<font size='3'>\red You are the Weyland Yutani PMC leader!</font>"
			mob << "<B> You must lead the PMCs to victory against any and all hostile threats.</b>"
			mob << "<B> Ensure no damage is incurred against Weyland Yutani. Make sure the CL is safe.</b>"
		else
			mob.mind.special_role = "MODE"
			if(prob(55)) //Randomize the heavy commandos and standard PMCs.
				spawn_standard(mob)
				mob << "<font size='3'>\red You are a Weyland Yutani tactical responder!</font>"
				mob << "<b> Follow your orders and protect W-Y interests. Make sure the CL is safe.</b>"
			else
				if(prob(50))
					spawn_heavy(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani sniper!</font>"
					mob << "<b> Follow your orders and protect W-Y interests. Make sure the CL is safe.</b>"
				else
					spawn_gunner(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani heavy gunner!</font>"
					mob << "<b> Follow your orders and protect W-Y interests. Make sure the CL is safe.</b>"
	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return


/datum/emergency_call/pmc/proc/spawn_standard(mob/M)
	if(!istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)

	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/PMC(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M.back), WEAR_IN_BACK)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Standard"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/pmc/proc/spawn_officer(mob/M)
	if(!istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M.back), WEAR_IN_BACK)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp78(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(M.back), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(M.back), WEAR_IN_BACK)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Officer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/pmc/proc/spawn_gunner(mob/M)
	if(!istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M), WEAR_R_STORE)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Specialist"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/pmc/proc/spawn_heavy(mob/M)
	if(!istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(M), WEAR_EYES)

	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M.back), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(M.back), WEAR_IN_BACK)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Sniper"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/pmc/proc/spawn_xenoborg(var/mob/M) //Deferred for now. Just keep it in mind
	return

/datum/emergency_call/xenos/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.
	var/chance = rand(0,2)
	var/mob/living/carbon/Xenomorph/new_xeno
	if(chance == 0)
		new_xeno = new /mob/living/carbon/Xenomorph/Hunter(spawn_loc)
	else if(chance == 1)
		new_xeno = new /mob/living/carbon/Xenomorph/Spitter(spawn_loc)
	else
		new_xeno = new /mob/living/carbon/Xenomorph/Drone(spawn_loc)

	new_xeno.jelly = 1
	new_xeno.key  = M.key

	if(original) //Just to be sure.
		del(original)

/datum/emergency_call/mercs/create_member(var/datum/mind/M, hostile)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "[pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Mercenary"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_captain(mob)
			if(hostility)
				mob << "<font size='3'>\red You are the Mercenary captain!</font>"
				mob << "<B> You must lead the mercs to victory against any and all hostile threats.</b>"
				mob << "<B> You are a space pirate responding to a distress. You are to loot the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
				mob << "<B> You hold no loyalty to the USCM and are in it for the money.</b>"
			else
				mob << "<font size='3'>\red You are the Mercenary captain!</font>"
				mob << "<B> You must lead the mercs to victory against any and all hostile threats.</b>"
				mob << "<B> You are to help with the defense of the [MAIN_SHIP_NAME], but you will not leave without payment.</b>"
				mob << "<B> You hold no loyalty to the USCM and are in it for the money.</b>"
		else
			spawn_mercenary(mob)
			if(hostility)
				mob << "<font size='3'>\red You are a Space Mercenary!</font>"
				mob << "<B> You are a space pirate responding to a distress. You are to loot the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
				mob << "<B> You hold no loyalty to the USCM and are in it for the money.</b>"
			else
				mob << "<font size='3'>\red You are a Space Mercenary!</font>"
				mob << "<B> You are to help with the defense of the [MAIN_SHIP_NAME], but you will not leave without payment.</b>"
				mob << "<B> You hold no loyalty to the USCM and are in it for the money.</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return

/datum/emergency_call/mercs/proc/spawn_captain(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/compression(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/compression(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), WEAR_FEET)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/heavy(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/heavy(M), WEAR_L_HAND)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Mercenary Captain"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_freelancer_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/mercs/proc/spawn_mercenary(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/compression(M), WEAR_JACKET)
	if(prob(50)) M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
	else M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/compression(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), WEAR_FEET)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Mercenary"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_freelancer_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

	spawn_merc_gun(M)
	spawn_merc_gun(M,1) //1 for the sidearm. l and r hands

/datum/emergency_call/bears/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Grigory","Vladimir","Alexei","Andrei","Artyom","Viktor","Boris","Ivan","Igor","Oleg")
	var/list/first_names_fr = list("Alexandra","Anna","Anastasiya","Eva","Klara","Oksana","Olga","Svetlana","Tatyana","Yaroslava")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Dragomirov","Yeltsin","Zhirov","Zhukov","Ivanov","Vasnetsov","Kasputin","Belov","Melnikov", "Vasilevsky", "Penkin")

	if(mob.gender == MALE) 	mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
	else 					mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)+"a"]"

	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "IRON BEARS"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are the Iron Bears leader!</font>"
			mob << "<B> You are a highly trained military cell and part of the Russian Spetsnaz.</b>"
			mob << "<B> You must lead the Iron Bears mercenaries in taking the [MAIN_SHIP_NAME] by taking over the bridge.</b>"
			mob << "<B> Make sure to contact the USSR and eliminate any resistance!</b>"
			mob << "<B> You're the only one they taught any English, so make use of that.</b>"
			mob << "\green Use say :3 <text> to speak in Russian. Works on comms too!"
		else
			spawn_standard(mob)
			mob.remove_language("Sol Common")
			mob.remove_language("English")
			mob << "<font size='3'>\red You are an Iron Bear mercenary!</font>"
			mob << "<font size='3'>\red You must take over the [MAIN_SHIP_NAME] at all costs! Listen to your leader!</font>"
			mob << "<font size='3'>\red Make sure to contact the USSR and eliminate any resistance!</font>"
			mob << "\green Use say :3 <text> to speak in Russian. Works on comms too!"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	mob.add_language("Russian")

	if(original)
		del(original)
	return


/datum/emergency_call/bears/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/bear(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/bear(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/bear(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/bear(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_L_STORE)

	spawn_slavic_gun(M)
	spawn_slavic_gun(M,1) //1 for the sidearm. l and r hands, 4 in backpack.

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Iron Bear"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/bears/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/bear(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/bear(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/bearpelt(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), WEAR_IN_BACK)

	spawn_slavic_gun(M)
	spawn_slavic_gun(M,1)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Iron Bears Sergeant"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/pizza/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "[pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Pizza"
	ticker.mode.traitors += mob.mind
	spawn(0)
		spawn_pizza(mob)
		var/pizzatxt = pick("Pizzachimp","Pizza the Hut","Papa Donks")
		mob << "<font size='3'>\red You are a pizza deliverer! Your employer is the [pizzatxt] Corporation.</font>"
		mob << "Your job is to deliver your pizzas. You're PRETTY sure this is the right place.."
	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return

/datum/emergency_call/pizza/proc/spawn_pizza(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/device/radio(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/vegetable(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/mushroom(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/meat(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Pizzachimp Deliverer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_freelancer_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

//Spawn various items around the shuttle area thing.
/datum/emergency_call/proc/spawn_items()
	return

/datum/emergency_call/pmc/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 3) //Spawns up to 3 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/pistol/vp78(drop_spawn)
					new /obj/item/weapon/gun/pistol/vp78(drop_spawn)
					new /obj/item/ammo_magazine/pistol/vp78
					new /obj/item/ammo_magazine/pistol/vp78
					continue
				if(1)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap
					new /obj/item/ammo_magazine/smg/m39/ap
					continue
				if(2)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new /obj/item/weapon/gun/rifle/m41a/elite(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a/elite(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary
					new /obj/item/ammo_magazine/rifle/incendiary
					continue
				if(5)
					new /obj/item/weapon/gun/launcher/m92(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(6)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					continue
				if(7)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					continue
	return

/datum/emergency_call/supplies/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 3) //Spawns up to 3 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/pistol/m4a3(drop_spawn)
					new /obj/item/weapon/gun/pistol/m1911(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/ap(drop_spawn)
					new /obj/item/ammo_magazine/pistol/incendiary(drop_spawn)
				if(1)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
				if(2)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
				if(4)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
				if(5)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
				if(6)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)
				if(7)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)

/datum/emergency_call/bears/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 3) //Spawns up to 3 random things.
		if(prob(10)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
				if(1)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(2)
					new /obj/item/weapon/reagent_containers/hypospray/tricordrazine(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					continue
				if(5)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
				if(6)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					continue
				if(7)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue

/datum/emergency_call/colonist/create_member(datum/mind/M) //Blank ERT with only basic items.
	var/turf/T = get_spawn_point()
	var/mob/original = M.current

	if(!istype(T)) r_FAL

	var/mob/living/carbon/human/H = new(T)
	H.gender = pick(MALE, FEMALE)
	var/datum/preferences/A = new
	A.randomize_appearance_for(H)
	H.real_name = capitalize(pick(H.gender == MALE ? first_names_male : first_names_female)) + " " + capitalize(pick(last_names))
	H.name = H.real_name
	H.age = rand(21,45)
	H.dna.ready_dna(H)
	H.key = M.key
	H.mind.assigned_role = "Colonist"
	H.mind.special_role = "MODE"
	ticker.mode.traitors += H.mind

	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot(new /obj/item/weapon/combat_knife(H), WEAR_L_STORE)
	H.equip_to_slot(new /obj/item/device/flashlight(H), WEAR_R_STORE)

	spawn(20)
		if(H && H.loc)
			H << "<span class='role_header'>You are a colonist!</span>"
			H << "<span class='role_body'>You have been put into the game by a staff member. Please follow all staff instructions.</span>"

	if(original && original.loc) cdel(original)

/datum/emergency_call/dutch/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE)
	var/datum/preferences/A = new()
	var/list/first_names_mr = list("Alan","Rick","Billy","Blain","Al","Mac","Jorge","Jim","Poncho")
	var/list/last_names_r = list("Hawkins","Sole","Elliot","Dillon","Cooper","Ramirez")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
	else
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
	A.randomize_appearance_for(mob)
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "DUTCH'S DOZEN"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
		/*
			mob.name = "Dutch Schaefer"
			mob.age = 38
			mob.s_tone = 35
			mob.h_style = "pompadour"
			mob.f_style = "shaved"
			mob.r_hair = 125
			mob.g_hair = 95
			mob.b_hair = 75
		*/
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are in charge of the mercenary team!</font>"
			mob << "<B> Lead your mercenary team to assist the Colonial Marines. You have been paid to do it, but you do not listen to USCM commands.</b>"
			mob << "<B> Should you encounter a Yautja, you are to hunt it down at all costs. If the shuttle is called, you must get to it.</b>"
			mob << "<B> You have prior knowledge of existance of the Yautja, but you are not to tell anyone about them!</b>"
		else
			spawn_standard(mob)
			mob << "<font size='3'>\red You are a member of Dutch's Mercenary team!</font>"
			mob << "<B> Should you encounter a Yautja, you are to hunt it down at all costs. If the shuttle is called, you must get to it.</b>"
			mob << "<B> You have prior knowledge of existance of the Yautja, but you are not to tell anyone about them!</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return


/datum/emergency_call/dutch/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/dutch(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/dutch(M), WEAR_JACKET)
	//M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/dutch/cap(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)

	spawn_merc_gun(M)
	spawn_merc_gun(M,1)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Dutch's Team Mercenary"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/dutch/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/dutch/ranger(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/dutch(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/dutch/band(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(M), WEAR_WAIST)

	spawn_merc_gun(M)
	spawn_merc_gun(M,1)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Dutch's Team Leader"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

	M.add_language("Russian")
	M.add_language("Sainja")


// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/death/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE)
	//var/datum/preferences/A = new()
	//A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Alpha","Beta","Delta","Gamma","Epsilon","Omega","Zeta","Theta","Lambda","Sigma")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)]"
	else
		mob.real_name = "[pick(first_names_mr)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "DEATH SQUAD"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are the Commando Leader!</font>"
			mob << "<B> You must clear out any traces of the infestation and it's survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"
		else
			spawn_standard(mob)
			mob << "<font size='3'>\red You are a Weyland-Yutani Commando!!</font>"
			mob << "<B> You must clear out any traces of the infestation and it's survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return


/datum/emergency_call/death/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Commando"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/death/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_L_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Commando Leader"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)
