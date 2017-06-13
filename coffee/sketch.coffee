
vinkelX = 90 # grader
vinkelY = 0

lastX = 0
lastY = 0

cmd0 = {}
cmd1 = {}
cmd2 = {}
cmd3 = {}

stack = []
rstack = [] # return stack

timestamp = 0

words = {}

saveCanvasCount = 0

settings = {}
i=0
j=0
k=0
t=0

fillSelect = (sel, arr) ->
	sel.empty()
	for key in arr
		sel.append($("<option>").attr('value', key).text(key))

codechange = (textarea) ->
	settings.code = textarea.value
	saveSettings()
	trace()

loadInt = (name,value) ->
	v = localStorage["Forth3D/"+name]
	settings[name] = if v? then int(v) else value

loadString = (name,value) ->
	v = localStorage["Forth3D/"+name]
	settings[name] = if v? then v else value

loadSettings = -> # från localStorage till settings, fixar default
	loadString 'code', '5 bitijk + + 3 ='
	loadInt 'font', 32
	loadInt 'n', 3
	loadInt 'fps', 10
	loadInt 'fig', 0 # sphere or box
	loadInt 'grid', 1
	loadInt 'rotate', 0
	loadInt 'debug', 0
	loadInt 'i', 0
	loadInt 'j', 0
	loadInt 'k', 0
	loadInt 't', 0
	loadInt 'SIZE', 400/settings.n
	loadString 'scaling', '1.0'

saveSettings = ->
	for name,value of settings
		localStorage["Forth3D/"+name] = value

sel0click = (sel) ->
	settings.scaling = sel.value
	saveSettings()

sel1click = (sel) ->
	settings.n = int sel.value
	settings.SIZE = int 400/settings.n
	saveSettings()
	fillSelect $('#sel19'), (2 ** i for i in range settings.n)
	fillSelect $('#sel15'), range settings.n # i
	fillSelect $('#sel16'), range settings.n # j
	fillSelect $('#sel17'), range settings.n # k
	$('#sel15').val '0'
	$('#sel16').val '0'
	$('#sel17').val '0'

sel3click = (sel) ->
	settings.fps = int sel.value
	saveSettings()
	frameRate settings.fps

sel14click = (sel) ->
	settings.font = sel.value
	document.getElementById("code").style.fontSize = settings.font + 'px'
	saveSettings()
sel15click = (sel) ->
	settings.i = int sel.value
	saveSettings()
	trace()
sel16click = (sel) ->
	settings.j = int sel.value
	saveSettings()
	trace()
sel17click = (sel) ->
	settings.k = int sel.value
	saveSettings()
	trace()
sel18click = (sel) ->
	settings.t = int sel.value
	saveSettings()
	trace()

btn6click = ->
	settings.fig = 1 - settings.fig
	saveSettings()
btn7click = ->
	settings.grid = 1 - settings.grid
	saveSettings()
btn9click = ->
	settings.rotate = 1 - settings.rotate
	saveSettings()

btn8click = ->
	settings.debug = 1 - settings.debug
	saveSettings()
	displayDebug()

displayDebug = ->
	for id in '#btn15 #btn16 #btn17 #btn18 #sel15 #sel16 #sel17 #sel18 #sel19 #tabell'.split ' '
		control = $ id
		if settings.debug==1 then control.show() else control.hide()

btn19click = -> saveCanvasCount++

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = parseInt sel15.value
	j = parseInt sel16.value
	k = parseInt sel17.value
	t = parseInt sel18.value
	calc true

linkAppend = (t, link, text) -> # exakt en kolumn
	d = (s) -> "'" + s + "'"
	dd = (s) -> '"' + s + '"'
	row = t.insertRow -1
	cell1 = row.insertCell -1
	s = '<a href=' + d(link)
	s += ' target=' + d('_blank')
	s += ' onmouseover=' + d('this.style.color=' + dd('yellow') + ';')
	s += ' onmouseout='  + d('this.style.color=' + dd('black') + ';')
	s += '>'
	s += text
	s += '</a>'
	cell1.innerHTML = s

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
	cmd2['=']    = (a,b) => [digit b == a]
	cmd2['<=']   = (a,b) => [digit b <= a]
	cmd2['>=']   = (a,b) => [digit b >= a]
	cmd2['<>']   = (a,b) => [digit b != a]
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

standard = (name,value) -> if localStorage[name]? then localStorage[name] else value

setup = ->
	c = createCanvas 800,800,WEBGL

	c.parent 'canvas'

	buildCommands()

	code = $ '#code'

	sel0 = $ '#sel0'
	sel1 = $ '#sel1'
	sel3 = $ '#sel3'

	sel14 = $ '#sel14'
	sel15 = $ '#sel15'
	sel16 = $ '#sel16'
	sel17 = $ '#sel17'
	sel18 = $ '#sel18'
	sel19 = $ '#sel19'

	tabell = $ '#tabell'
	#links = $ '#links' # Sätts tydligen automatiskt utifrån id

	p1 = $ '#p1'
	p2 = $ '#p2'
	p3 = $ '#p3'

	loadSettings()
	print settings

	fillSelect sel0, '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split ' ' # scaling
	fillSelect sel1, range 2, 28 # n
	fillSelect sel3, range 26 # fps

	fillSelect sel14, range 16,36,2 # font
	fillSelect sel15, range settings.n # i
	fillSelect sel16, range settings.n # j
	fillSelect sel17, range settings.n # k
	fillSelect sel18, range 10 # t
	fillSelect sel19, (2 ** i for i in range settings.n)

	sel0.val settings.scaling
	sel1.val settings.n
	sel3.val settings.fps

	sel14.val settings.font

	sel15.val settings.i
	sel16.val settings.j
	sel17.val settings.k
	sel18.val settings.t

	code.val settings.code

	document.getElementById("code").style.fontSize = settings.font + 'px'

	linkAppend links, "https://github.com/ChristerNilsson/p5Forth3D#p5forth3d", "Help"
	linkAppend links, "examples2x2x2.html", "Examples 2x2x2"
	linkAppend links, "examples3x3x3.html", "Examples 3x3x3"
	linkAppend links, "examples.html", "Examples"

	frameRate settings.fps

	# removes error message: [.Offscreen-For-WebGL-000000000571CD90]RENDER WARNING: there is no texture bound to the unit 0
	texture createGraphics 1,1
	displayDebug()

digit = (bool) -> if bool then 1 else 0
showStack = (level,cmd) -> tableAppend tabell, level + cmd, stack.join ' '
showError = (e) -> tableAppend tabell, e[0], e[1], '#FF0000'
gcd = (x, y) -> if y == 0 then x else gcd y, x % y

mousePressed = ->
	if 0 < mouseX < width and 0 < mouseY < height
		lastX=mouseX
		lastY=mouseY
mouseDragged = ->
	if 0 < mouseX < width and 0 < mouseY < height
		dx = mouseX-lastX
		dy = mouseY-lastY
		vinkelX += dx/4
		vinkelY += dy/4
		lastX=mouseX
		lastY=mouseY

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
	arr = code.value.replace(/\n/g,' ').split ' '
	state = 'normal'
	defWords = []
	stateStack = []
	try
		for cmd in arr
			if cmd == '(' then stateStack.push '('
			if cmd == '' then continue
			if cmd == ':' then stateStack.push ':'
			if _.last(stateStack) == '('
				if cmd == ')' then stateStack.pop()
			else if _.last(stateStack) == ':'
				defWords.push cmd
				if cmd == ';'
					if defWords.length == 3 then delete words[defWords[0]]
					else words[defWords[1]] = defWords[2..-2].join ' '
					defWords = []
					stateStack.pop()
			else
				evaluate traceFlag, cmd
		stack.length==1 and 0 != _.last stack
	catch e
		if traceFlag then showError e

draw = ->
	drawFigure = (s) ->
		s = _.max [int(s),5]
		u = int s/2
		if settings.fig == 0 then sphere u,u,u else box s,s,s
		showSelected u
	showSelected = (u) ->
		if settings.debug == 0 then return
		if i0 != i then return
		if j0 != j then return
		if k0 != k then return
		specularMaterial 0,255,0
		cylinder u/5,2.2*u
		rotateX radians 90
		specularMaterial 0,0,255
		cylinder u/5,2.2*u
		rotateZ radians 90
		specularMaterial 255,0,0
		cylinder u/5,2.2*u

	if settings.fps == 0 then return
	trace()
	bg 0.5

	if 0 < mouseX < width and 0 < mouseY < height
		locX = 2 * mouseX / width - 1
		locY = 1 - 2 * mouseY / height
	else
		locX = -(1 - 2 * lastX / height)
		locY = -(2 * lastY / width - 1)

	if settings.rotate == 1
		vinkelY += 1
		vinkelX += 0.5

	rotateX radians vinkelY
	rotateY radians vinkelX

	ambientLight 128, 128,128
	pointLight 255, 255, 255, locX,locY,0.25

	i0 = settings.i
	j0 = settings.j
	k0 = settings.k

	t = frameCount
	count = 0
	scaling = parseFloat settings.scaling
	for i in range settings.n
		for j in range settings.n
			for k in range settings.n
				push()
				x = settings.SIZE * (0.5+i-settings.n/2)
				y = settings.SIZE * (0.5+j-settings.n/2)
				z = settings.SIZE * (0.5+k-settings.n/2)
				translate x,y,z

				f = 255/(settings.n-1)
				specularMaterial f*i, f*j, f*k

				if calc()
					drawFigure scaling * settings.SIZE
					count++
				else
					if settings.grid == 1 then drawFigure scaling * 2*settings.SIZE/10
				pop()

	arr = code.value.replace(/\n/g,' ').split ' '
	arr = (item for item in arr when item.length > 0)
	p1.innerHTML = 'Words: ' + arr.length
	p2.innerHTML = 'Figures: ' + count
	if millis() > timestamp
		p3.innerHTML = "FPS: #{nf(frameRate(),0,1)}"
		timestamp = millis() + 1000
	#if frameCount < 100 then save "out-#{frameCount}.png"
	if saveCanvasCount > 0
		saveCanvas 'p5Forth3D', 'png'
		saveCanvasCount--

tableClear = -> $("#tabell tr").remove()

tableAppend = (t, a, b, col='#80808000') ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = a
	cell2.innerHTML = b
	cell1.style.backgroundColor = '#C0C0C000'
	cell1.style.color = '#FFFFFF'
	cell2.style.backgroundColor = col
	cell2.style.textAlign = 'right'