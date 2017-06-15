class Settings
	constructor : -> @get = {}

	load : (name,value) ->
		v = localStorage["Forth3D/"+name]
		@get[name] = if v? then v else value

	loadInt : (name,value) ->
		v = int localStorage["Forth3D/"+name]
		@get[name] = if v? then v else value

	set : (name,value) ->
		localStorage["Forth3D/"+name] = value
		@get[name] = value

class Button
	constructor : (x,y,w,h,txt,@lst,val,@action) ->
		@index = @lst.indexOf val
		@button1 = createButton txt
		@button1.position x,y
		@button1.size w,h
		@button2 = createButton @value()
		@button2.position x+w,y
		@button2.size w,h
		@button1.mousePressed () =>
			@index = (@index-1) %% @lst.length
			@button2.html @value()
			@action()
		@button2.mousePressed () =>
			@index = (@index+1) %% @lst.length
			@button2.html @value()
			@action()
	value : -> @lst[@index]
	setLst : (lst) ->
		@lst = lst
		if @index >= @lst.length
			@index = @lst.length - 1
			@button2.html @value()
	hide : ->
		@button1.hide()
		@button2.hide()
	show : ->
		@button1.show()
		@button2.show()

class NormalButton
	constructor : (x,y,w,h,txt,@action) ->
		@button = createButton txt
		@button.position x,y
		@button.size w,h
		@button.mousePressed () => @action()

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

settings = new Settings
i=0
j=0
k=0
t=0

btni = null
btnj = null
btnk = null
btnt = null

codechange = (textarea) ->
	settings.set 'code', textarea.value
	trace()

loadSettings = -> # från localStorage till settings, fixar default
	settings.load 'code', '5 bitijk + + 3 ='
	settings.loadInt 'font', 32
	settings.loadInt 'n', 3
	settings.loadInt 'fps', 10
	settings.load 'fig', 'sphere' # sphere or box
	settings.load 'grid', 'yes'
	settings.load 'rotate', 'yes'
	settings.loadInt 'debug', 0
	settings.loadInt 'i', 0
	settings.loadInt 'j', 0
	settings.loadInt 'k', 0
	settings.loadInt 't', 0
	settings.loadInt 'SIZE', 400/settings.get.n
	settings.load 'scaling', '1.0'

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = btni.value()
	j = btnj.value()
	k = btnk.value()
	# t = parseInt sel18.value
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
	tabell = $ '#tabell'

	p1 = $ '#p1'
	p2 = $ '#p2'
	p3 = $ '#p3'

	loadSettings()

	code.val settings.get.code

	document.getElementById("code").style.fontSize = settings.get.font + 'px'

	linkAppend links, "https://github.com/ChristerNilsson/p5Forth3D#p5forth3d", "Help"
	linkAppend links, "examples2x2x2.html", "Examples 2x2x2"
	linkAppend links, "examples3x3x3.html", "Examples 3x3x3"
	linkAppend links, "examples.html", "Examples"

	frameRate settings.get.fps

	# removes error message: [.Offscreen-For-WebGL-000000000571CD90]RENDER WARNING: there is no texture bound to the unit 0
	texture createGraphics 1,1

	new Button 0,305,50,20,'font',range(16,40,2), settings.get.font, () ->
		settings.set 'font', @value()
		document.getElementById("code").style.fontSize = settings.get.font + 'px'

	new Button 0,325,50,20,'size','0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split(' '), settings.get.scaling, () -> settings.set 'scaling', @lst[@index]

	new Button 0,345,50,20,'n',range(2,28), settings.get.n, () ->
		settings.set 'n', int @value()
		btni.setLst range settings.get.n
		btnj.setLst range settings.get.n
		btnk.setLst range settings.get.n
		settings.set 'SIZE', int 400/settings.get.n

	new Button 0,365,50,20,'fps',range(26), settings.get.fps, () ->
		settings.set 'fps', int @value()
		frameRate settings.get.fps

	btni = new Button 380,305,50,20,'i',range(settings.get.n), settings.get.i, () ->
		settings.set 'i', int @value()
		trace()

	btnj = new Button 380,325,50,20,'j',range(settings.get.n), settings.get.j, () ->
		settings.set 'j', int @value()
		trace()

	btnk = new Button 380,345,50,20,'k',range(settings.get.n), settings.get.k, () ->
		settings.set 'k', int @value()
		trace()

	btni.button2.style 'color','red'
	btnj.button2.style 'color','green'
	btnk.button2.style 'color','blue'

	btnt = new Button 380,365,50,20,'t',range(10), settings.get.t, () ->
		settings.set 't', int @value()
		trace()

	new Button 0,400,50,20,'fig', 'sphere box'.split(' '), settings.get.fig, () ->
		settings.set 'fig', @value()
		trace()

	new Button 0,420,50,20,'grid', 'yes no'.split(' '), settings.get.grid, () ->
		settings.set 'grid', @value()
		trace()

	new Button 0,440,50,20,'rotate', 'yes no'.split(' '), settings.get.rotate, () ->
		settings.set 'rotate', @value()
		trace()

	new NormalButton 0,460,50,20,'save', () ->
		saveCanvasCount++

	new NormalButton 0,480,50,20,'debug', () ->
		settings.set 'debug', 1 - settings.get.debug
		displayDebug()

	displayDebug()

displayDebug = =>
	if settings.get.debug == 1 then btni.show() else btni.hide()
	if settings.get.debug == 1 then btnj.show() else btnj.hide()
	if settings.get.debug == 1 then btnk.show() else btnk.hide()
	if settings.get.debug == 1 then btnt.show() else btnt.hide()
	for id in '#tabell'.split ' '
		control = $ id
		if settings.get.debug == 1 then control.show() else control.hide()

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
	drawFigure = (s) =>
		s = _.max [int(s),5]
		u = int s/2
		if settings.get.fig == 'sphere' then sphere u,u,u else box s,s,s
	showAxes = =>
		if settings.get.debug == 0 then return
		if i0 != i then return
		if j0 != j then return
		if k0 != k then return

		size = settings.get.SIZE
		len = (settings.get.n-1) * size

		push() # y
		translate 0,size * (settings.get.n/2 - 1/2 - j),0
		specularMaterial 0,255,0
		cylinder size/50,len
		pop()

		push() # z
		translate 0,0,size * (settings.get.n/2 - 1/2 - k)
		rotateX radians 90
		specularMaterial 0,0,255
		cylinder size/50,len
		pop()

		push() # x
		translate size * (settings.get.n/2 - 1/2 - i),0,0
		rotateZ radians 90
		specularMaterial 255,0,0
		cylinder size/50,len
		pop()

	if settings.get.fps == 0 then return
	trace()
	bg 0.5

	if 0 < mouseX < width and 0 < mouseY < height
		locX = 2 * mouseX / width - 1
		locY = 1 - 2 * mouseY / height
	else
		locX = -(1 - 2 * lastX / height)
		locY = -(2 * lastY / width - 1)

	if settings.get.rotate == 'yes'
		vinkelY += 1
		vinkelX += 0.5

	rotateX radians vinkelY
	rotateY radians vinkelX

	ambientLight 128, 128,128
	pointLight 255, 255, 255, locX,locY,0.25

	i0 = settings.get.i
	j0 = settings.get.j
	k0 = settings.get.k

	t = frameCount
	count = 0
	scaling = parseFloat settings.get.scaling
	for i in range settings.get.n
		for j in range settings.get.n
			for k in range settings.get.n
				push()
				x = settings.get.SIZE * (0.5+i-settings.get.n/2)
				y = settings.get.SIZE * (0.5+j-settings.get.n/2)
				z = settings.get.SIZE * (0.5+k-settings.get.n/2)
				translate x,y,z

				f = 255/(settings.get.n-1)
				specularMaterial f*i, f*j, f*k #,alpha

				if calc()
					drawFigure scaling * settings.get.SIZE
					count++
				else
					if settings.get.grid == 'yes'
						drawFigure scaling * 2*settings.get.SIZE/10
				showAxes()
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