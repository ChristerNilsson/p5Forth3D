N = 10
SIZE = 250/N

lightX = 250
lightY = 250

cmd0 = {}
cmd1 = {}
cmd2 = {}
cmd3 = {}

stack = []
rstack = [] # return stack

i = 0
j = 0
k = 0
t = 0
timestamp = 0

words = {}

fillSelect = (sel, arr) ->
	sel.empty()
	for key in arr
		sel.append($("<option>").attr('value', key).text(key))

codechange = (sel) -> draw()

sel0click = (sel) ->
sel3click = (sel) -> frameRate int sel.value
sel5click = (sel) ->
sel6click = (sel) ->
sel7click = (sel) ->
sel8click = (sel) ->

sel15click = (sel) -> trace()
sel16click = (sel) -> trace()
sel17click = (sel) -> trace()
sel18click = (sel) -> trace()

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = parseInt sel15.value
	j = parseInt sel16.value
	k = parseInt sel17.value
	t = parseInt sel18.value
	calc true

buildCommands = ->
	cmd0['i']          = => [i]
	cmd0['j']          = => [j]
	cmd0['k']          = => [k]
	cmd0['t']          = => [t]
	cmd0['pop']        = => [rstack.pop()]

	cmd1['push']   = (a) =>
		rstack.push a
		[]
	cmd1['drop']   = (a) => []
	cmd1['dup']    = (a) => [a,a]
	cmd1['not']    = (a) => [digit a == 0]
	cmd1['inv']    = (a) => [1 / a]
	cmd1['chs']    = (a) => [-a]
	cmd1['sign']   = (a) => [Math.sign a]
	cmd1['abs']    = (a) => [abs a]
	cmd1['sqrt']   = (a) => [sqrt a]
	cmd1['rot']    = (a) => [a]
	cmd1['~']      = (a) => [~a]
	cmd1['biti']   = (a) => [a >> i & 1]
	cmd1['bitj']   = (a) => [a >> j & 1]
	cmd1['bitk']   = (a) => [a >> k & 1]
	cmd1['bitij']  = (a) => [a >> i & 1, a >> j & 1]
	cmd1['bitik']  = (a) => [a >> i & 1, a >> k & 1]
	cmd1['bitjk']  = (a) => [a >> j & 1, a >> k & 1]
	cmd1['bitijk'] = (a) => [a >> i & 1, a >> j & 1, a >> k & 1]

	cmd2['swap'] = (a,b) => [a,b]
	cmd2['<']    = (a,b) => [digit b < a]
	cmd2['>']    = (a,b) => [digit b > a]
	cmd2['==']   = (a,b) => [digit b == a]
	cmd2['<=']   = (a,b) => [digit b <= a]
	cmd2['>=']   = (a,b) => [digit b >= a]
	cmd2['!=']   = (a,b) => [digit b != a]
	cmd2['+']    = (a,b) => [b + a]
	cmd2['-']    = (a,b) => [b - a]
	cmd2['*']    = (a,b) => [b * a]
	cmd2['**']   = (a,b) => [b ** a]
	cmd2['/']    = (a,b) => [b / a]
	cmd2['//']   = (a,b) => [b // a]
	cmd2['%']    = (a,b) => [b % a]
	cmd2['%%']   = (a,b) => [b %% a]
	cmd2['gcd']  = (a,b) => [gcd a,b]
	cmd2['bit']  = (a,b) => [a >> b & 1]
	cmd2['&']    = (a,b) => [b & a]
	cmd2['|']    = (a,b) => [b | a]
	cmd2['^']    = (a,b) => [b ^ a]
	cmd2['>>']   = (a,b) =>	[b >> a]
	cmd2['<<']   = (a,b) => [b << a]
	cmd2['and']  = (a,b) => [digit b!=0 and a!=0]
	cmd2['or']   = (a,b) =>	[digit b!=0 or a!=0]
	cmd2['xor']  = (a,b) => [digit b+a == 1]

	cmd3['rot']  = (c,b,a) => [b,c,a]
	cmd3['-rot'] = (c,b,a) => [c,a,b]

setup = ->
	c = createCanvas 500,500,WEBGL
	c.parent 'canvas'

	buildCommands()

	code = $ '#code'

	sel0 = $ '#sel0'
	sel3 = $ '#sel3'
	sel5 = $ '#sel5'
	sel6 = $ '#sel6'
	sel7 = $ '#sel7'
	sel8 = $ '#sel8'

	sel15 = $ '#sel15'
	sel16 = $ '#sel16'
	sel17 = $ '#sel17'
	sel18 = $ '#sel18'
	sel19 = $ '#sel19'

	tabell = $ '#tabell'

	p1 = $ '#p1'
	p2 = $ '#p2'
	p3 = $ '#p3'

	fillSelect sel0, range 1, 21 # radius
	fillSelect sel3, range 1,21 # frameRate
	fillSelect sel5, '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split ' ' # alpha
	fillSelect sel6, ['sphere','box'] # fig
	fillSelect sel7, ['yes','no'] # grid
	fillSelect sel8, '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split ' ' # bg

	fillSelect sel15, range 10 #
	fillSelect sel16, range 10 # i
	fillSelect sel17, range 10 # j
	fillSelect sel18, range 10 # k
	fillSelect sel19, [1,2,4,8,16,32,64,128,256,512]

	frameRate 10

	sel0.val("12").change() # radius
	sel3.val("10").change() # fps
	sel5.val("1.0").change() # alpha
	sel6.val("sphere").change() # fig
	sel7.val("yes").change() # grid
	sel8.val("0.5").change() # bg

	sel15.val("0").change() # i
	sel16.val("0").change() # j
	sel17.val("0").change() # k
	sel18.val("0").change() # t

	trace()

digit = (bool) -> if bool then 1 else 0
showStack = (level,cmd) -> tableAppend tabell, level + cmd, stack.join ' '
showError = (e) -> tableAppend tabell, e[0], e[1], '#FF0000'
gcd = (x, y) -> if y == 0 then x else gcd y, x % y

evaluate = (traceFlag, line, level='') ->
	arr = line.split ' '
	for cmd in arr
		if cmd=='' then # do nothing
		else if words[cmd]?
			if level.indexOf('.'+cmd+'.') != -1 then throw [level+cmd,'Recursion not allowed']
			evaluate traceFlag, words[cmd], level + cmd + '.'
		else if cmd3[cmd]?
			if stack.length < 3 then throw [level+cmd,'Stack Underflow']
			stack = stack.concat cmd3[cmd] stack.pop(), stack.pop(), stack.pop()
			if traceFlag then showStack level,cmd
		else if cmd2[cmd]?
			if stack.length < 2 then throw [level+cmd,'Stack Underflow']
			stack = stack.concat cmd2[cmd] stack.pop(), stack.pop()
			if traceFlag then showStack level,cmd
		else if cmd1[cmd]?
			if stack.length < 1 then throw [level+cmd,'Stack Underflow']
			stack = stack.concat cmd1[cmd] if cmd=='rot' then stack.shift() else stack.pop()
			if traceFlag then showStack level,cmd
		else if cmd0[cmd]?
			stack = stack.concat cmd0[cmd]()
			if traceFlag then showStack level,cmd
		else
			nr = parseFloat cmd
			if _.isNumber(nr) and not _.isNaN nr
				stack.push nr
				if traceFlag then showStack level,cmd
			else
				throw [level+cmd,'Unknown Word']

calc = (traceFlag = false) ->
	words = {}
	stack = []
	rstack = []
	lines = code.value.split "\n"
	try
		for line in lines
			if 0 == line.indexOf ':'
				arr = line.split ' '
				if arr.length == 3 and arr[2] == ';'
					delete words[arr[1]]
				else
					words[arr[1]] = arr[2..-2].join ' '
			else
				evaluate traceFlag, line
		0 != _.last stack
	catch e
		if traceFlag then showError e

draw = ->

	trace()
	bg sel8.value

	orbitControl()

	if 0 < mouseX < width and 0 < mouseY < height
		locX = 1 - 2 * mouseX / height
		locY = 2 * mouseY / width - 1
	else
		locX = 1 - 2 * lightX / height
		locY = 2 * lightY / width - 1

	alpha = sel5.value

	pointLight 255, 255, 255, locX,locY,0

	t = frameCount
	count = 0
	radius = sel0.value
	for i in range N
		for j in range N
			for k in range N
				push()
				translate SIZE*(0.5+i-N/2),SIZE*(0.5+j-N/2),SIZE*(0.5+k-N/2)

				f = 255/(N-1)
				specularMaterial f*i, f*j, f*k, 255*sel5.value

				if calc()
					if sel6.value == 'sphere' then sphere radius,radius,radius else	box 2*radius,2*radius,2*radius
					count++
				else
					if sel7.value == 'yes' then	sphere 2,2,2
				pop()

	arr = code.value.replace(/\n/g,' ').split(' ')
	arr = (item for item in arr when item.length > 0)
	p1.innerHTML = 'Words: ' + arr.length
	p2.innerHTML = 'Cubes: ' + count
	if millis() > timestamp
		p3.innerHTML = 'FPS: ' + int frameRate()
		timestamp = millis() + 1000

tableClear = -> $("#tabell tr").remove()

tableAppend = (t, a, b, col='#C0C0C0') ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = a
	cell2.innerHTML = b
	cell1.style.backgroundColor = '#808080'
	cell2.style.backgroundColor = col
	cell2.style.textAlign = 'right'