class Settings
	constructor : -> @get = {}

	load : (name,value) ->
		v = localStorage["Forth3D/settings/"+name]
		@get[name] = if v? then v else value

	loadInt : (name,value) ->
		v = int localStorage["Forth3D/settings/"+name]
		@get[name] = if v? then v else value

	set : (name,value) ->
		localStorage["Forth3D/settings/"+name] = value
		@get[name] = value

class Button
	constructor : (x,y,w,h,txt,@lst,val,@wrap,@action) ->
		@index = @lst.indexOf val
		@button1 = createButton txt
		@button1.position x,y
		@button1.size w,h
		@button2 = createButton @value()
		@button2.position x+w,y
		@button2.size w,h
		@button1.mousePressed () =>
			if @wrap
				@index = (@index-1) %% @lst.length
			else if @index>0
				@index--
			@button2.html @value()
			@action()
		@button2.mousePressed () =>
			if @wrap
				@index = (@index+1) %% @lst.length
			else if @index < @lst.length-1
				@index++
			@button2.html @value()
			@action()
	value : -> @lst[@index]
	set : (value) ->
		@index = @lst.indexOf value
		@button2.html @value()
	setLst : (lst) ->
		@lst = lst
		if @index >= @lst.length
			@index = @lst.length - 1
			@button2.html @value()
	visible : (b) ->
		if b then @button1.show() else @button1.hide()
		if b then @button2.show() else @button2.hide()
	disabled : (b) ->
		@button1.elt.disabled = b
		@button2.elt.disabled = b

class NormalButton
	constructor : (x,y,w,h,txt,@action) ->
		@button = createButton txt
		@button.position x,y
		@button.size w,h
		@button.mousePressed () => @action()

class Exercise # contains current problem
	constructor : (@level) ->
		current = data[@level]
		@dims = current[1]   # data
		@n = current[2]      # data
		@code_a = current[3] # data
		@code_b = localStorage['Forth3D/code/' + @level]
		if not @code_b? then @code_b = ''
		@update()

	update : ->
		@words_a = calcWords @code_a
		@words_b = calcWords @code_b
		@pattern_a = calcCubes @code_a
		@pattern_b = calcCubes @code_b
		if @pattern_a == @pattern_b
			@score = 10
			diff = @words_a - @words_b
			if diff > 0 then @score += 10 * diff else @score += diff
			if @score <= 0 then @score = 1
		else
			@score = 0
		localStorage['Forth3D/score/' + @level]	= @score
		score.innerHTML = 'Score: ' + @score
		if @score == 0 then score.style.color = 'red'
		else if @score >= 10 then score.style.color = 'lightgreen'
		else score.style.color = 'yellow'

		words1.innerHTML = @words_a
		words2.innerHTML = @words_b
		words2.style.color = if @words_a >= @words_b then 'lightgreen' else 'red'

		cubes1.innerHTML = countChar @pattern_a,'1'
		cubes = countChar @pattern_b,'1'
		cubes2.innerHTML = cubes
		cubes2.style.color = if @pattern_a == @pattern_b then 'lightgreen' else 'red'

		totalScore = 0
		for key in _.keys data
			tmp = localStorage['Forth3D/score/' + key]
			if tmp? then totalScore += int tmp
		total.innerHTML = 'Total: ' + totalScore

countChar = (s,ch) ->
	count = 0
	for c in s
		if c==ch then count++
	count

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

current = ''
exercise = null

settings = new Settings
i=0
j=0
k=0

btni = null
btnj = null
btnk = null
btnt = null
btnDims = null
btnn = null
btnRotate = null
btnLevel = null

codechange = (textarea) ->
	#settings.set 'code', textarea.value
	localStorage['Forth3D/code/'+settings.get.level] = textarea.value
	exercise.code_b = textarea.value
	exercise.update()
	trace()

loadSettings = -> # från localStorage till settings, fixar default
	settings.loadInt 'font', 32
	settings.loadInt 'n', 2
	settings.loadInt 'fps', 10
	settings.loadInt 'i', 0
	settings.loadInt 'j', 0
	settings.loadInt 'k', 0
	settings.loadInt 'SIZE', 200/settings.get.n
	settings.load 'level', 'a01'
	settings.load 'dims', '1D'
	settings.load 'code', ''
	settings.load 'fig', 'sphere' # sphere or box
	settings.load 'grid', 'yes'
	settings.load 'rotate', 'no'
	settings.load 'debug', 'no'
	settings.load 'scaling', '1.0'

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = btni.value()
	j = btnj.value()
	k = btnk.value()
	calc code.value, true

linkAppend = (t, link, text) -> # exakt en kolumn
	d = (s) -> "'" + s + "'"
	dd = (s) -> '"' + s + '"'
	row = t.insertRow -1
	cell1 = row.insertCell -1
	s = '<x href=' + d(link)
	s += ' target=' + d('_blank')
	s += ' onmouseover=' + d('this.style.color=' + dd('yellow') + ';')
	s += ' onmouseout='  + d('this.style.color=' + dd('black') + ';')
	s += '>'
	s += text
	s += '</x>'
	cell1.innerHTML = s

buildCommands = ->
	cmd0['i']          = => [i]
	cmd0['j']          = => [j]
	cmd0['k']          = => [k]
	cmd0['pop']        = => [rstack.pop()]

	cmd1['push']   = (x) =>
		rstack.push x
		[]
	cmd1['drop']   = (x) => []
	cmd1['dup']    = (x) => [x,x]
	cmd1['not']    = (x) => [digit x == 0]
	cmd1['inv']    = (x) => [1 / x]
	cmd1['chs']    = (x) => [-x]
	cmd1['sign']   = (x) => [Math.sign x]
	cmd1['abs']    = (x) => [abs x]
	cmd1['sqrt']   = (x) => [sqrt x]
	cmd1['rot']    = (x) => [x]
	cmd1['~']      = (x) => [~x]
	cmd1['biti']   = (x) => [x >> i & 1]
	cmd1['bitj']   = (x) => [x >> j & 1]
	cmd1['bitk']   = (x) => [x >> k & 1]
	cmd1['bitij']  = (x) => [x >> i & 1, x >> j & 1]
	cmd1['bitik']  = (x) => [x >> i & 1, x >> k & 1]
	cmd1['bitjk']  = (x) => [x >> j & 1, x >> k & 1]
	cmd1['bitijk'] = (x) => [x >> i & 1, x >> j & 1, x >> k & 1]

	cmd2['swap'] = (x,y) => [x,y]
	cmd2['<']    = (x,y) => [digit y < x]
	cmd2['>']    = (x,y) => [digit y > x]
	cmd2['=']    = (x,y) => [digit y == x]
	cmd2['<=']   = (x,y) => [digit y <= x]
	cmd2['>=']   = (x,y) => [digit y >= x]
	cmd2['<>']   = (x,y) => [digit y != x]
	cmd2['+']    = (x,y) => [y + x]
	cmd2['-']    = (x,y) => [y - x]
	cmd2['*']    = (x,y) => [y * x]
	cmd2['**']   = (x,y) => [y ** x]
	cmd2['/']    = (x,y) => [y / x]
	cmd2['//']   = (x,y) => [y // x]
	cmd2['%']    = (x,y) => [y % x]
	cmd2['%%']   = (x,y) => [y %% x]
	cmd2['gcd']  = (x,y) => [gcd y,x]
	cmd2['bit']  = (x,y) => [x >> y & 1]
	cmd2['&']    = (x,y) => [y & x]
	cmd2['|']    = (x,y) => [y | x]
	cmd2['^']    = (x,y) => [y ^ x]
	cmd2['>>']   = (x,y) =>	[y >> x]
	cmd2['<<']   = (x,y) => [y << x]
	cmd2['and']  = (x,y) => [digit y!=0 and x!=0]
	cmd2['or']   = (x,y) =>	[digit y!=0 or x!=0]
	cmd2['xor']  = (x,y) => [digit y+x == 1]
	cmd2['2dup'] = (x,y) => [y,x,y,x]

	cmd3['rot']  = (x,y,z) => [y,x,z]
	cmd3['-rot'] = (x,y,z) => [x,z,y]

standard = (name,value) -> if localStorage[name]? then localStorage[name] else value

setup = ->
	c = createCanvas 400,800,WEBGL
	c.parent 'canvas'

	buildCommands()
	code = $ '#code'
	tabell = $ '#tabell'

	p3 = $ '#p3'

	loadSettings()

	#code.val settings.get.code

	document.getElementById("code").style.fontSize = settings.get.font + 'px'

	# linkAppend links, "examples2x2x2.html", "Examples 2x2x2"
	# linkAppend links, "examples3x3x3.html", "Examples 3x3x3"
	# linkAppend links, "examples.html", "Examples"

	frameRate settings.get.fps

	# removes error message: [.Offscreen-For-WebGL-000000000571CD90]RENDER WARNING: there is no texture bound to the unit 0
	texture createGraphics 1,1

###########################

	btnDims = new Button 0,0,50,20,'dims',['1D','2D','3D'], settings.get.dims, () ->
		settings.set 'dims', @value()
		displayDebug()
	btnDims.disabled true

	btnn = new Button 0,20,50,20,'n',range(2,28), settings.get.n, () ->
		settings.set 'n', int @value()
		btni.setLst range settings.get.n
		btnj.setLst range settings.get.n
		btnk.setLst range settings.get.n
		settings.set 'SIZE', int 200/settings.get.n
	btnn.disabled true

	new Button 0,40,50,20,'size','0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split(' '), settings.get.scaling, true, () -> settings.set 'scaling', @lst[@index]

	new Button 0,60,50,20,'fps',range(26), settings.get.fps, true, () ->
		settings.set 'fps', int @value()
		frameRate settings.get.fps

	new Button 0,80,50,20,'font',range(16,40,2), settings.get.font, true, () ->
		settings.set 'font', @value()
		document.getElementById("code").style.fontSize = settings.get.font + 'px'

###########################

	new Button 120,0,50,20,'figure', 'sphere box'.split(' '), settings.get.fig, true, () ->
		settings.set 'fig', @value()
		trace()

	btnRotate = new Button 120,20,50,20,'rotate', 'yes no'.split(' '), settings.get.rotate, true, () ->
		settings.set 'rotate', @value()
		trace()

	new Button 120,40,50,20,'grid', 'yes no'.split(' '), settings.get.grid, true, () ->
		settings.set 'grid', @value()
		trace()

	new Button 120,60,50,20,'debug', 'yes no'.split(' '), settings.get.debug, true, () ->
		settings.set 'debug', @value()
		displayDebug()

	new NormalButton 120,80,100,20,'snapshot', () ->
		saveCanvasCount++

###########################

	btni = new Button 120,120,50,20,'i',range(settings.get.n), settings.get.i, true, () ->
		settings.set 'i', int @value()
		trace()

	btnj = new Button 120,140,50,20,'j',range(settings.get.n), settings.get.j, true, () ->
		settings.set 'j', int @value()
		trace()

	btnk = new Button 120,160,50,20,'k',range(settings.get.n), settings.get.k, true, () ->
		settings.set 'k', int @value()
		trace()

	btnLevel = new Button 120,200,50,20,'level', _.keys(data), settings.get.level, false, () ->
		settings.set 'level', @value()
		setLevel()

###########################

	btni.button1.style 'color','white'
	btnj.button1.style 'color','white'
	btnk.button1.style 'color','white'
	btni.button1.style 'background-color','red'
	btnj.button1.style 'background-color','green'
	btnk.button1.style 'background-color','blue'

	setLevel()
	displayDebug()

setLevel =  ->
	source = localStorage['Forth3D/code/' + settings.get.level]
	code.value = if source? then source else ''

	current = data[settings.get.level]
	settings.set 'dims',current[1]
	settings.set 'n',current[2]
	settings.set 'SIZE', int 200/settings.get.n

	exercise = new Exercise settings.get.level

	btnDims.set current[1]
	btnRotate.disabled settings.get.dims in ['1D','2D']
	btnn.set current[2]
	if settings.get.dims in ['1D','2D']
		vinkelX = 90
		vinkelY = 0
	if settings.get.dims == '3D'
		vinkelX = 45
		vinkelY = 45
	displayDebug()
	trace()

displayDebug = =>
	btni.visible settings.get.debug == 'yes'
	btnj.visible settings.get.debug == 'yes' and settings.get.dims >= '2D'
	btnk.visible settings.get.debug == 'yes' and settings.get.dims >= '3D'
	control = $ '#tabell'
	if settings.get.debug == 'yes' then control.show() else control.hide()

digit = (bool) -> if bool then 1 else 0
showStack = (level,cmd) -> tableAppend tabell, level + cmd, stack.join ' '
showError = (e) -> tableAppend tabell, e[0], e[1], '#FF0000'
gcd = (x, y) -> if y == 0 then x else gcd y, x % y

mousePressed = ->
	if 0 < mouseX < width and 0 < mouseY < height and settings.get.dims == '3D'
		lastX=mouseX
		lastY=mouseY
mouseDragged = ->
	if 0 < mouseX < width and 0 < mouseY < height and settings.get.dims == '3D'
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

calc = (sourcecode, traceFlag = false) ->
	words = {}
	stack = []
	rstack = []
	arr = sourcecode.replace(/\n/g,' ').split ' '
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
		stack.length==1 and 1 == _.last stack
	catch e
		if traceFlag then showError e

draw = ->
	bg 0.5

	ambientLight 128, 128,128
	pointLight 255, 255, 255, 0.5,0.5,0.25

	push()
	drawOne current[3], -200,16,words1,cubes1
	pop()

	push()
	drawOne code.value, 200,-16,words2,cubes2
	pop()

	#if frameCount < 100 then save "out-#{frameCount}.png"
	if saveCanvasCount > 0
		saveCanvas 'p5Forth3D', 'png'
		saveCanvasCount--

drawOne = (sourcecode, yOffset,vOffset,words,cubes) ->

	drawFigure = (s) =>
		s = _.max [int(s),5]
		u = int s/2
		if settings.get.fig == 'sphere' then sphere u,u,u else box s,s,s
	showAxes = =>
		if settings.get.debug == 'no' then return

		i0 = 0
		j0 = 0
		k0 = 0

		size = settings.get.SIZE
		n = settings.get.n
		len = size * (n-1)

		x = size * (0.5+i0-n/2)
		y = size * (0.5+(n-1-j0)-n/2)
		z = size * (0.5+k0-n/2)
		push()
		translate z,y,x

		push() # x
		translate 0,0,-x
		rotateX radians 90
		specularMaterial 255,0,0
		cylinder size/50,len
		pop()

		if settings.get.dims >= '2D'
			push() # y
			translate 0,-y,0
			specularMaterial 0,255,0
			cylinder size/50,len
			pop()

		if settings.get.dims == '3D'
			push() # z
			translate -z,0,0
			rotateZ radians 90
			specularMaterial 0,0,255
			cylinder size/50,len
			pop()

		pop()

	drawCurrent = (radius,len) =>
		if settings.get.debug == 'no' then return

		i0 = settings.get.i
		j0 = settings.get.j
		k0 = settings.get.k
		if (i0==i and j0==j and k0==k) == false then return

		push() # x
		rotateX radians 90
		specularMaterial 255,0,0
		cylinder radius,len
		pop()

		push() # y
		specularMaterial 0,255,0
		cylinder radius,len
		pop()

		push() # z
		rotateZ radians 90
		specularMaterial 0,0,255
		cylinder radius,len
		pop()

	if settings.get.fps == 0 then return
	trace()

	if settings.get.rotate == 'yes'
		vinkelY += 1
		vinkelX += 0.5

	translate 0,yOffset,0

	rotateX radians vinkelY+vOffset
	rotateY radians vinkelX

	count = 0
	scaling = parseFloat settings.get.scaling
	size = settings.get.SIZE
	n = settings.get.n
	jvalues = if settings.get.dims == '1D' then range 1 else range n
	kvalues = if settings.get.dims <= '2D' then range 1 else range n
	for i in range n
		for j in jvalues
			for k in kvalues
				push()
				x = size * (0.5+i-n/2)
				y = size * (0.5+(n-1-j)-n/2)
				z = size * (0.5+k-n/2)
				translate z,y,x

				f = 255/(n-1)
				specularMaterial f*i, f*j, f*k #,alpha

				if calc sourcecode
					drawFigure scaling * size
					drawCurrent scaling * 2*size/10,scaling * size
					count++
				else
					if settings.get.grid == 'yes'
						drawFigure scaling * size/5
						drawCurrent scaling * 2*size/50, scaling * size/5
				pop()
	showAxes()

	if millis() > timestamp
		p3.innerHTML = "FPS: #{nf(frameRate(),0,1)}"
		timestamp = millis() + 1000

calcWords = (sourcecode) ->
	arr = sourcecode.replace(/\n/g,' ').split ' '
	arr = (item for item in arr when item.length > 0)
	arr.length

calcCubes = (sourcecode) ->
	n = settings.get.n
	jvalues = if settings.get.dims == '1D' then range 1 else range n
	kvalues = if settings.get.dims <= '2D' then range 1 else range n
	res = ''
	for i in range n
		for j in jvalues
			for k in kvalues
				res += if calc sourcecode then '1' else '0'
	res

tableClear = -> $("#tabell tr").remove()

tableAppend = (t, x, b, col='#80808000') ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = x
	cell2.innerHTML = b
	cell1.style.backgroundColor = '#C0C0C000'
	cell2.style.color = '#FFFFFF'
	cell2.style.backgroundColor = col
	cell2.style.textAlign = 'right'