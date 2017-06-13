N = 10
SIZE = 400/N

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

i = 0
j = 0
k = 0
t = 0
timestamp = 0

words = {}

saveCanvasCount = 0

debug = true

fillSelect = (sel, arr) ->
	sel.empty()
	for key in arr
		sel.append($("<option>").attr('value', key).text(key))

codechange = (textarea) ->
	setSetting 'code', textarea.value
	trace()

setSetting = (name,value) -> localStorage["Forth3D/"+name] = value
getSetting = (name,value) ->
	v = localStorage["Forth3D/"+name]
	if v? then v else value

sel0click = (sel) -> setSetting 'size', sel.value
sel1click = (sel) ->
	setSetting 'n', sel.value
	N = int sel.value
	SIZE = int 400/N
	fillSelect $('#sel19'), (2 ** i for i in range N)
	fillSelect $('#sel15'), range N # i
	fillSelect $('#sel16'), range N # j
	fillSelect $('#sel17'), range N # k
	$('#sel15').val '0'
	$('#sel16').val '0'
	$('#sel17').val '0'

sel3click = (sel) ->
	setSetting 'fps', sel.value
	frameRate int sel.value
sel6click = (sel) -> setSetting 'fig', sel.value
sel7click = (sel) -> setSetting 'grid', sel.value
sel9click = (sel) -> setSetting 'rotate', sel.value

sel14click = (sel) ->
	setSetting 'font', sel.value
	document.getElementById("code").style.fontSize = sel.value + 'px'
sel15click = (sel) ->
	setSetting 'i', sel.value
	trace()
sel16click = (sel) ->
	setSetting 'j', sel.value
	trace()
sel17click = (sel) ->
	setSetting 'k', sel.value
	trace()
sel18click = (sel) ->
	setSetting 't', sel.value
	trace()

btn8click = ->
	debug = not debug
	if debug then $('#btn15').show() else $('#btn15').hide()
	if debug then $('#btn16').show() else $('#btn16').hide()
	if debug then $('#btn17').show() else $('#btn17').hide()
	if debug then $('#btn18').show() else $('#btn18').hide()
	if debug then $('#sel15').show() else $('#sel15').hide()
	if debug then $('#sel16').show() else $('#sel16').hide()
	if debug then $('#sel17').show() else $('#sel17').hide()
	if debug then $('#sel18').show() else $('#sel18').hide()
	if debug then $('#sel19').show() else $('#sel19').hide()
	if debug then $('#tabell').show() else $('#tabell').hide()

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
	cmd2['=']   = (a,b) => [digit b == a]
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
	sel6 = $ '#sel6'
	sel7 = $ '#sel7'
	#sel8 = $ '#sel8'
	sel9 = $ '#sel9'

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

	N = getSetting "n",'10'

	fillSelect sel0, '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split ' ' # size
	fillSelect sel1, range 2, 28 # n
	fillSelect sel3, range 26 # fps
	fillSelect sel6, ['sphere','box'] # fig
	fillSelect sel7, ['yes','no'] # grid
	#fillSelect sel8, '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split ' ' # bg
	fillSelect sel9, ['yes','no'] # rotate

	fillSelect sel14, range 16,36,2 # font
	fillSelect sel15, range N # i
	fillSelect sel16, range N # j
	fillSelect sel17, range N # k
	fillSelect sel18, range 10 # t
	fillSelect sel19, (2 ** i for i in range N)

	sel0.val getSetting "size",'1.0'
	sel1.val getSetting "n",'10'
	sel3.val getSetting "fps",'10'
	sel6.val getSetting "fig",'sphere'
	sel7.val getSetting "grid",'yes'
	#sel8.val getSetting "bg",'0.5'
	sel9.val getSetting "rotate",'no'

	sel14.val getSetting "font",'26'
	sel15.val getSetting "i",'0'
	sel16.val getSetting "j",'0'
	sel17.val getSetting "k",'0'
	sel18.val getSetting "t",'0'

	code.val getSetting 'code', '5 bitijk + + 3 ='

	document.getElementById("code").style.fontSize = sel14.value + 'px'

	linkAppend links, "https://github.com/ChristerNilsson/p5Forth3D#p5forth3d", "Help"
	linkAppend links, "examples2x2x2.html", "Examples 2x2x2"
	linkAppend links, "examples3x3x3.html", "Examples 3x3x3"
	linkAppend links, "examples.html", "Examples"

	N = getSetting 'n', 10
	SIZE = int 400/N
	frameRate int getSetting 'fps', 10

	# removes error message: [.Offscreen-For-WebGL-000000000571CD90]RENDER WARNING: there is no texture bound to the unit 0
	texture createGraphics 1,1
	btn8click()

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
		if sel6.value == 'sphere' then sphere u,u,u else box s,s,s
		showSelected u
	showSelected = (u) ->
		if not debug then return
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

	if sel3.value == '0' then return
	trace()
	bg 0.5

	if 0 < mouseX < width and 0 < mouseY < height
		locX = 2 * mouseX / width - 1
		locY = 1 - 2 * mouseY / height
	else
		locX = -(1 - 2 * lastX / height)
		locY = -(2 * lastY / width - 1)

	if 'yes' == getSetting 'rotate','no'
		vinkelY += 1
		vinkelX += 0.5

	rotateX radians vinkelY
	rotateY radians vinkelX

	ambientLight 128, 128,128
	pointLight 255, 255, 255, locX,locY,0.25

	i0 = parseInt sel15.value
	j0 = parseInt sel16.value
	k0 = parseInt sel17.value

	t = frameCount
	count = 0
	size = sel0.value
	for i in range N
		for j in range N
			for k in range N
				push()
				translate SIZE*(0.5+i-N/2),SIZE*(0.5+j-N/2),SIZE*(0.5+k-N/2)

				f = 255/(N-1)
				specularMaterial f*i, f*j, f*k

				if calc()
					drawFigure size * SIZE
					count++
				else
					if sel7.value == 'yes' then drawFigure size * 2*SIZE/10
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