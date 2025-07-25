GLOBAL_LIST_INIT(department_radio_keys, list(
	":i" = RADIO_CHANNEL_INTERCOM, ".i" = RADIO_CHANNEL_INTERCOM, "#i" = RADIO_CHANNEL_INTERCOM,
	":h" = RADIO_CHANNEL_DEPARTMENT, ".h" = RADIO_CHANNEL_DEPARTMENT, "#h" = RADIO_CHANNEL_DEPARTMENT,
	":w" = RADIO_MODE_WHISPER, ".w" = RADIO_MODE_WHISPER, "#w" = RADIO_MODE_WHISPER,

	":+" = RADIO_CHANNEL_SPECIAL, ".+" = RADIO_CHANNEL_SPECIAL, "#+" = RADIO_CHANNEL_SPECIAL, //activate radio-specific special functions

	":a" = SQUAD_MARINE_1, ".a" = SQUAD_MARINE_1, "#a" = RADIO_CHANNEL_CLF_MED,
	":b" = SQUAD_MARINE_2, ".b" = SQUAD_MARINE_2, "#b" = RADIO_CHANNEL_CLF_ENGI,
	":c" = SQUAD_MARINE_3, ".c" = SQUAD_MARINE_3, "#c" = RADIO_CHANNEL_CIA,
	":d" = SQUAD_MARINE_4, ".d" = SQUAD_MARINE_4, "#d" = RADIO_CHANNEL_CLF_CCT,
	":e" = SQUAD_MARINE_5, ".e" = SQUAD_MARINE_5, "#e" = RADIO_CHANNEL_PMC_ENGI,
	":f" = SQUAD_MARINE_CRYO, ".f" = SQUAD_MARINE_CRYO, "#f" = RADIO_CHANNEL_PMC_MED,
	":g" = RADIO_CHANNEL_ALMAYER, ".g" = RADIO_CHANNEL_ALMAYER, "#g" = RADIO_CHANNEL_CLF_GEN,
	":j" = RADIO_CHANNEL_JTAC, ".j" = RADIO_CHANNEL_JTAC, "#j" = RADIO_CHANNEL_UPP_CCT,
	":k" = SQUAD_SOF, ".k" = SQUAD_SOF, "#k" = RADIO_CHANNEL_WY_WO,
	"#l" = RADIO_CHANNEL_PROVOST, //l . and : reserved for Left hand
	":m" = RADIO_CHANNEL_MEDSCI, ".m" = RADIO_CHANNEL_MEDSCI, "#m" = RADIO_CHANNEL_UPP_MED,
	":n" = RADIO_CHANNEL_ENGI, ".n" = RADIO_CHANNEL_ENGI, "#n" = RADIO_CHANNEL_UPP_ENGI,
	":o" = RADIO_CHANNEL_COLONY, ".o" = RADIO_CHANNEL_COLONY, "#o" = RADIO_CHANNEL_PMC_CCT,
	":p" = RADIO_CHANNEL_MP , ".p" = RADIO_CHANNEL_MP , "#p" = RADIO_CHANNEL_PMC_GEN,
	":q" = RADIO_CHANNEL_ROYAL_MARINE, ".q" = RADIO_CHANNEL_ROYAL_MARINE, "#q" = RADIO_CHANNEL_ROYAL_MARINE,
	"#r" = RADIO_CHANNEL_YAUTJA, //r .r and :r reserved for Right hand
	":s" = RADIO_CHANNEL_US_ARMY, ".s" = RADIO_CHANNEL_US_ARMY, "#s" = RADIO_CHANNEL_US_ARMY,
	":t" = RADIO_CHANNEL_INTEL, ".t" = RADIO_CHANNEL_INTEL, "#t" = RADIO_CHANNEL_UPP_KDO,
	":u" = RADIO_CHANNEL_REQ, ".u" = RADIO_CHANNEL_REQ, "#u" = RADIO_CHANNEL_UPP_GEN,
	":v" = RADIO_CHANNEL_COMMAND , ".v" = RADIO_CHANNEL_COMMAND , "#v" = RADIO_CHANNEL_UPP_CMD,
	":x" = RADIO_CHANNEL_USASF, ".x" = RADIO_CHANNEL_USASF, "#x" = RADIO_CHANNEL_USASF,
	":y" = RADIO_CHANNEL_WY, ".y" = RADIO_CHANNEL_WY, "#y" = RADIO_CHANNEL_WY,
	":z" = RADIO_CHANNEL_HIGHCOM, ".z" = RADIO_CHANNEL_HIGHCOM, "#z" = RADIO_CHANNEL_PMC_CMD,

	":0" = RADIO_CHANNEL_UA_GUARD, ".0" = RADIO_CHANNEL_UA_GUARD, "#0" = RADIO_CHANNEL_UA_GUARD,
	":1" = RADIO_CHANNEL_USASF, ".1" = RADIO_CHANNEL_USASF, "#1" = RADIO_CHANNEL_USASF,
	":2" = RADIO_CHANNEL_REBEL_UA, ".2" = RADIO_CHANNEL_REBEL_UA, "#2" = RADIO_CHANNEL_REBEL_UA,
	":3" = RADIO_CHANNEL_REBEL_TWE, ".3" = RADIO_CHANNEL_REBEL_TWE, "#3" = RADIO_CHANNEL_REBEL_TWE,
	//4-9 available, CLF not in use, channels available for overwrite.
))

/proc/channel_to_prefix(channel)
	var/channel_key
	for(var/key in GLOB.department_radio_keys)
		if(GLOB.department_radio_keys[key] == channel)
			channel_key = key
			break
	return channel_key

/proc/prefix_to_channel(prefix)
	return GLOB.department_radio_keys[lowertext(prefix)]

/proc/filter_message(client/user, message)
	if(!config.word_filter_regex)
		return TRUE

	if(config.word_filter_regex.Find(message))
		to_chat(user,
			html = "\n<font color='red' size='4'><b>-- Word Filter Message --</b></font>",
			)
		to_chat(user,
			type = MESSAGE_TYPE_ADMINPM,
			html = "\n<font color='red' size='4'><b>Your message has been automatically filtered due to its contents. Trying to circumvent this filter will get you banned.</b></font>",
			)
		SEND_SOUND(user, sound('sound/effects/adminhelp_new.ogg'))
		log_admin("[user.ckey] triggered the chat filter with the following message: [message].")
		return FALSE

	return TRUE

///Shows custom speech bubbles for screaming, *warcry etc.
/mob/living/proc/show_speech_bubble(bubble_name, bubble_type = bubble_icon)

	var/mutable_appearance/speech_bubble = mutable_appearance('icons/mob/effects/talk.dmi', "[bubble_icon][bubble_name]", TYPING_LAYER)
	speech_bubble.pixel_x = bubble_icon_x_offset
	speech_bubble.pixel_y = bubble_icon_y_offset

	overlays += speech_bubble

	addtimer(CALLBACK(src, PROC_REF(remove_speech_bubble), speech_bubble), 3 SECONDS)

/mob/living/proc/remove_speech_bubble(mutable_appearance/speech_bubble, list_of_mobs)
	overlays -= speech_bubble

/mob/living/say(message, datum/language/speaking = null, verb="says", alt_name="", italics=0, message_range = GLOB.world_view_size, sound/speech_sound, sound_vol, nolog = 0, message_mode = null, bubble_type = bubble_icon)
	var/turf/T

	if(SEND_SIGNAL(src, COMSIG_LIVING_SPEAK, message, speaking, verb, alt_name, italics, message_range, speech_sound, sound_vol, nolog, message_mode) & COMPONENT_OVERRIDE_SPEAK) return

	if(!filter_message(src, message))
		return

	message = process_chat_markup(message, list("~", "_"))

	for(var/dst=0; dst<=1; dst++) //Will run twice if src has a clone
		if(!dst && src.clone) //Will speak in src's location and the clone's
			T = locate(src.loc.x + src.clone.proj_x, src.loc.y + src.clone.proj_y, src.loc.z + src.clone.proj_z)
		else
			T = get_turf(src)
			dst++ //Only speak once

		//handle nonverbal and sign languages here
		if (speaking)
			if (speaking.flags & NONVERBAL)
				if (prob(30))
					manual_emote(pick(speaking.signlang_verb))

			if (speaking.flags & SIGNLANG)
				say_signlang(message, pick(speaking.signlang_verb), speaking)
				return 1

		var/list/listening = list()
		var/list/listening_obj = list()

		if(HAS_TRAIT(src, TRAIT_LISPING))
			var/old_message = message
			message = lisp_replace(message)
			if(old_message != message)
				verb = "lisps"

		if(T)
			var/list/hearturfs = list()

			for(var/I in hear(message_range, T))
				if(istype(I, /mob/))
					var/mob/M = I
					listening += M
					hearturfs += M.locs[1]
					for(var/obj/O in M.contents)
						var/obj/item/clothing/worn_item = O
						if((O.flags_atom & USES_HEARING) || ((istype(worn_item) && worn_item.accessories)))
							listening_obj |= O
				else if(istype(I, /obj/structure/surface))
					var/obj/structure/surface/table = I
					hearturfs += table.locs[1]
					for(var/obj/O in table.contents)
						if(O.flags_atom & USES_HEARING)
							listening_obj |= O
				else if(istype(I, /obj/))
					var/obj/O = I
					hearturfs += O.locs[1]
					if(O.flags_atom & USES_HEARING)
						listening_obj |= O

			for(var/mob/M as anything in GLOB.player_list)
				if((M.stat == DEAD || isobserver(M)) && M.client && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTEARS))
					listening |= M
					continue
				if(M.loc && (M.locs[1] in hearturfs))
					listening |= M

		var/speech_bubble_test = say_test(message)
		var/image/speech_bubble = image('icons/mob/effects/talk.dmi', src, "[bubble_type][speech_bubble_test]", FLY_LAYER)

		var/not_dead_speaker = (stat != DEAD)
		if(not_dead_speaker)
			langchat_speech(message, listening, speaking)
		for(var/mob/M as anything in listening)
			M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol)
		overlays += speech_bubble

		addtimer(CALLBACK(src, PROC_REF(remove_speech_bubble), speech_bubble), 3 SECONDS)

		for(var/obj/O as anything in listening_obj)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking, italics)

	//used for STUI to stop logging of animal messages and radio
	//if(!nolog)
	//Rather see stuff twice then not at all.

	// Log people differently, first, check if they are human
	if(ishuman(src))
		if(message_mode) // we are talking into a radio
			if(message_mode == "headset") // default value, means general
				message_mode = "General"
			log_say("[name != "Unknown" ? name : "([real_name])"] \[[message_mode]\]: [message] (CKEY: [key]) (JOB: [job]) (AREA: [get_area_name(loc)])")
		else // we talk normally
			log_say("[name != "Unknown" ? name : "([real_name])"]: [message] (CKEY: [key]) (JOB: [job]) (AREA: [get_area_name(loc)])")
	else
		log_say("[name != "Unknown" ? name : "([real_name])"]: [message] (CKEY: [key]) (AREA: [get_area_name(loc)])")

	return 1

/mob/living/proc/say_signlang(message, verb="gestures", datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name
