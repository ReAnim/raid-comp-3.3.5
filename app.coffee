# raid composition for 3.3.5
# inspired by http://raidcomp.mmo-champion.com/
# written by Murlorc
# version 0.094

# list of all classes
classes = ["warrior", "paladin", "deathknight",
			"shaman", "hunter",
			"druid", "rogue",
			"mage", "priest", "warlock"]
# list of all specs
specs =
	"warrior" : ['fury', 'arms', 'prot'],
	"paladin" : ['prot', 'holy', 'ret'],
	"deathknight" : ['blood', 'frost', 'unholy'],
	"shaman" : ['ele', 'enhancement', 'resto'],
	"hunter" : ['bm', 'mm', 'survival'],
	"druid" : ['balance', 'feral', 'resto'],
	"rogue" : ['assassin', 'combat', 'subtlety'],
	"mage" : ['arcane', 'fire', 'frost'],
	"priest" : ['disc', 'holy', 'shadow'],
	"warlock" : ['aff', 'demo', 'destro']

# raid groups
groups = []
for i in [1..5]
	groups.push "group#{i}"

# default unit frame information
defaultUnitFrame =
	'display' : 'block',
	'backgroundColor' : '#111'
	'fontWeight': 'normal'

# generic complement
complement = (element, array) ->
	comp = []
	for e in array
		comp.push e if e isnt element
	comp

# return all classes that aren't the input
classComplement = (klass) -> complement(klass, classes)
# return all specs that aren't the input
specComplement = (klass, spec) -> complement(spec, specs[klass])

showRoles = (klass, spec) ->

	show = (role) -> $(".roles div.#{role}").show()
	hide = (role) -> $(".roles div.#{role}").hide()

	# deal with all healers
	if spec in ["holy", "disc", "resto"]
		show('heal')
		hide('tank')
		hide('dps')
	# deal with pure tank specs
	else if spec is "prot"
		show('tank')
		hide('dps')
		hide('heal')
	# deal with tank/dps hybrid specs >(
	else if spec in ["feral", "unholy", "blood"]
		show('tank')
		show('dps')
		hide('heal')
	else
		show('dps')
		hide('tank')
		hide('heal')
	if spec is "frost"
		if klass is "mage"
			show('dps')
			hide('tank')
			hide('heal')
		else
			show('dps')
			show('tank')
			hide('heal')
		

# show all specs in the chosen class
classSpecsHandler = (klass) ->

	$(".classes .#{klass}").click ->
		
		# hide any roles that are showing since we have to rechoose a spec
		if not $(this).hasClass('selected')
			$('.roles div').hide()
			$('.specs div span').removeClass('selected')
			$('.info span.spec').text("")
			$('.info span.role').text("")
			$("#ok").hide()
		
		# highlight the clicked frame
		$(this).addClass('selected')

		for c in classComplement(klass)
			# remove underline from other classes
			$(".classes .#{c}").removeClass('selected')
			# hide other classes' specs
			$(".specs .#{c}").hide()
		
		# show what specs this class has available
		$(".specs .#{klass}").show()
		
		# update the info text
		$('.info span.klass').text(klass)


# show all roles in the chosen spec
specRolesHandler = (klass, spec) ->

	$(".specs .#{klass} .#{spec}").click ->

		# reset things to the right
		if not $(this).hasClass('selected')
			$('.roles span').removeClass('selected')
			$('.info span.role').text("")
			$('#ok').hide()

		# remove other highlights
		for s in specComplement(klass, spec)
			$(".specs .#{klass} .#{s}").removeClass('selected')

		# highlight the clicked frame
		$(this).addClass('selected')

		# show what roles this spec can take
		showRoles(klass, spec)

		# update info text
		$('.info span.spec').text(spec)

# after clicking a role, the new invitation is completely determined
roleHandler = (role) ->

	$(".roles .#{role} span").click ->

		# highlight this role
		$(this).addClass('selected')

		# unhighlight other roles
		for other in ["dps", "tank", "heal"]
			if other isnt role
				$(".roles .#{other} span").removeClass('selected')

		# update info text
		$(".info span.role").text(role)

		# show the OK button
		$('#ok').show()

# reset everything
resetInviter = ->

	# hide the OK button
	$('#ok').hide()

	# hide the roles, unhighlight them
	$(".roles div").hide().find('span').removeClass('selected')

	# hide the specs, unhighlight
	$(".specs div").hide().find('span').removeClass('selected')

	# unhighlight the class
	$(".classes span").removeClass('selected')

	# reset info text
	$('span.spec, span.klass, span.role').text("")

resetInviterHandler = ->

	$('#reset').click (event) ->
		
		# prevent default click action 
		event.preventDefault()

		resetInviter()

# find the first empty slot in the raid
findNextEmptySlot = ->

	groupHasEmptySlot = (group) ->

		slots = $(".raid .#{group} div")

		for slot in slots

			if $(slot).find('span').text().length is 0
				return true

		return false

	getNextEmptySlotInGroup = (group) ->
		# assumes group has an empty slot
		slots = $(".raid .#{group} div")

		for slot in slots

			if $(slot).find('span').text().length is 0
				return slot

	for group in groups

		if groupHasEmptySlot(group)

			return getNextEmptySlotInGroup(group)

	throw Error

# add unit to raidframe
addUnitToRaidFrame = (klass, spec, role) ->

	try # get first empty slot available
		slot = findNextEmptySlot()
		$(slot).addClass(klass).find('span').addClass(spec).text(role)
	catch error
		alert "There are no more empty slots."
	

# send out invite
invite = ->

	# function to update status role counter
	updateStatsRoleCount = (role) ->

		# get current counter
		current = parseInt($(".stats .roles .#{role}").text())
		# update counter with 1 more
		$(".stats .roles .#{role}").text(current + 1)

	updateStatsDpsCount = (dps) ->
		current = parseInt($(".stats .dps .#{dps}").text())
		$(".stats .dps .#{dps}").text(current + 1)

	updateClassCount = (klass) ->

		# find out how many of this class have been invited
		theCount = parseInt($(".classCount p.#{klass} span").text())
		
		# now add 1
		$(".classCount p.#{klass}").show().find('span').text(theCount + 1)

	# set the class
	for c in classes
		if $('.classes .selected').hasClass c
			klass = c

	# set the spec
	for s in specs[klass]
		if $(".specs .#{klass} .selected").hasClass s
			spec = s

	# set the role
	for roles in ["dps", "tank", "heal"]
		if $(".roles .#{roles} .selected").hasClass roles
			role = roles

	# update the role count
	updateStatsRoleCount role

	# update the dps stats
	if role is "dps"
		if klass in ["warrior", "paladin", "deathknight", "rogue"] or spec in ["feral", "enhancement"]
			updateStatsDpsCount("mdps")
		else
		# if klass in ["warlock", "mage", "priest", "hunter"] or spec in ["balance", "elemental"]
			updateStatsDpsCount("rdps")
		if klass in ["paladin", "shaman", "mage", "priest", "warlock"] or spec in ["balance", "enhancement", "survival", "assassin"]
			updateStatsDpsCount("magical")
		else
			updateStatsDpsCount("physical")

	# update the class count
	updateClassCount(klass)

	# update the raid frame
	addUnitToRaidFrame(klass, spec, role)

inviteHandler = ->
	$("#ok").click (event) ->

		# prevent default click action
		event.preventDefault()

		# resetInviter()
		invite()

		# reset everything
		resetInviter()

groupResetHandler = (group) ->
	$(".#{group} .groupName a.reset").click (event) ->

		event.preventDefault()

		for klass in classes
			if $(".#{group} div").hasClass(klass)
				$(".#{group} div")
					.removeClass(klass)
					.find('span')
					.removeClass()
					.addClass("frame","slot")
					.text("")

raidResetHandler = ->
	$(".stats .raidReset a.reset").click (event) ->

		event.preventDefault()

		for group in groups
			for klass in classes
				if $(".#{group} div").hasClass(klass)
					$(".#{group} div")
						.removeClass(klass)
						.find('span')
						.removeClass()
						.addClass("frame","slot")
						.text("")

# init
$ ->
	# initialize click handler for classes
	classSpecsHandler(klass) for klass in classes

	# initialize click handler for specs
	for klass in classes
		for spec in specs[klass]
			specRolesHandler(klass, spec)

	# initialize click handler for roles
	roleHandler(role) for role in ["dps", "tank", "heal"]

	# initialize handler for reset button
	resetInviterHandler()

	# initialize handler for OK button
	inviteHandler()

	# initialize handler for resetting groups
	groupResetHandler(group) for group in groups

	# initialize handler for resetting raid
	raidResetHandler()
