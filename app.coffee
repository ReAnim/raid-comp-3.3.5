# raid composition for 3.3.5
# inspired by http://raidcomp.mmo-champion.com/
# written by Murlorc
# version 0.02

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

		# highlight the clicked frame
		$(this).addClass('selected')

		for c in specComplement(klass, spec)
			# remove underline from other specs
			$(".specs .#{c}").removeClass('selected')

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

	$('#reset').click ->

		# prevent default click action
		event.preventDefault()
		
		# hide the OK button
		$('#ok').hide()

		# hide the roles
		$(".roles div").hide()

		# hide the specs
		$(".specs div").hide()

		# unhighlight the class
		$(".classes span").removeClass('selected')

		# reset info text
		$('span.spec, span.klass, span.role').text("")


# init
$ ->
	# initialize click handler for classes
	classSpecsHandler(klass) for klass in classes

	# initialize click handler for specs
	for klass in classes
		for spec in specs[klass]
			specRolesHandler(klass, spec)

	# initialize click handler for roles
	for role in ["dps", "tank", "heal"]
		roleHandler(role)

	# initialize handler for reset button
	resetInviter()

	# initialize handler for OK button
	# invite()