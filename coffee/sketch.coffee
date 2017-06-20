store = (name,value) -> # påverka EJ guit här!
	#if localStorage["Forth3D/settings/" + name] == value then return
	localStorage["Forth3D/settings/" + name] = value
	if name == 'debug' then	displayDebug()
	if name == 'font' then document.getElementById("code").style.fontSize = fetch('font') + 'px'
	if name == 'n'
		if fetch('dims') in ['1D','2D'] then Size = 250 else Size=200
		store 'SIZE', int Size/fetch('n')

	if name == 'fps' then frameRate fetch 'fps'
	if name in ['i','j','k','rotate','grid','figure'] then trace()

fetch = (name) ->
	s = localStorage["Forth3D/settings/" + name]
	print 'fetch',name,s
	if name in ['fps','font','i','j','k','n'] then int s else s

displayDebug = =>
	btni.visible fetch('debug') == 'yes'
	btnj.visible fetch('debug') == 'yes' and fetch('dims') >= '2D'
	btnk.visible fetch('debug') == 'yes' and fetch('dims') >= '3D'
	control = $ '#tabell'
	if fetch('debug') == 'yes' then control.show() else control.hide()

setDefault = (name,value) ->
	if not localStorage["Forth3D/settings/" + name]?
		localStorage["Forth3D/settings/" + name] = value

setDefaults = ->
	setDefault 'font', 32
	setDefault 'n', 2
	setDefault 'fps', 10
	setDefault 'SIZE', 200/fetch 'n'
	setDefault 'dims', '1D'
	setDefault 'size', '1.0'
	setDefault 'level', 'a01'
	setDefault 'figure', 'sphere'
	setDefault 'grid', 'yes'
	setDefault 'rotate', 'no'
	setDefault 'debug', 'no'
	setDefault 'i', 0
	setDefault 'j', 0
	setDefault 'k', 0

handler = () -> # Här är det ok att påverka guit.
	if @name() == 'snapshot' then saveCanvasCount++
	else if @name() in ['i','j','k','fps','font'] then store @name(), int @value()
	# else if @name() == 'n'
	# 	store @name(), @value()
	else if @name() == 'level'
		store @name(), @value()
		setLevel()
		displayDebug()
	else store @name(), @value()

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
	name : -> @button1.elt.innerText
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
	name : -> @button.elt.innerText

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

# current = ''
exercise = null

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
	localStorage['Forth3D/code/' + fetch('level')] = textarea.value
	exercise.code_b = textarea.value
	exercise.update()
	trace()

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
	cmd1['b2d']    = (x) => [parseInt x, 2]

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

	setDefaults()

###########################
	btnDims = new Button 0,0,50,20,'dims',['1D','2D','3D'], fetch('dims'), null
	btnn = new Button 0,20,50,20,'n',range(2,28), fetch('n'), null
	new Button 0,40,50,20,'size','0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'.split(' '), fetch('size'), true, handler
	new Button 0,60,50,20,'fps',range(26), fetch('fps'), true, handler
	new Button 0,80,50,20,'font',range(16,40,2), fetch('font'), true, handler
###########################
	new Button 120,0,50,20,'figure', 'sphere box'.split(' '), fetch('figure'), true, handler
	btnRotate = new Button 120,20,50,20,'rotate', 'yes no'.split(' '), fetch('rotate'), true, handler
	new Button 120,40,50,20,'grid', 'yes no'.split(' '), fetch('grid'), true, handler
	new Button 120,60,50,20,'debug', 'yes no'.split(' '), fetch('debug'), true, handler
	new NormalButton 120,80,100,20,'snapshot', handler
###########################
	btni = new Button 120,120,50,20,'i',range(fetch('n')), fetch('i'), true, handler
	btnj = new Button 120,140,50,20,'j',range(fetch('n')), fetch('j'), true, handler
	btnk = new Button 120,160,50,20,'k',range(fetch('n')), fetch('k'), true, handler
	btnLevel = new Button 60,220,50,20,'level', _.keys(data), fetch('level'), false, handler
###########################

	btnDims.disabled true
	btnn.disabled true
	btni.button1.style 'color','white'
	btnj.button1.style 'color','white'
	btnk.button1.style 'color','white'
	btni.button1.style 'background-color','red'
	btnj.button1.style 'background-color','green'
	btnk.button1.style 'background-color','blue'

	store 'font',fetch('font')
	store 'fps', fetch('fps')
	setLevel()
	displayDebug()
	texture createGraphics 1,1 # removes error message: [.Offscreen-For-WebGL-000000000571CD90]RENDER WARNING: there is no texture bound to the unit 0

setLevel =  ->
	source = localStorage['Forth3D/code/' + fetch('level')]
	code.value = if source? then source else ''

	current = data[fetch('level')]
	store 'dims', current[1]
	store 'n', current[2]

	exercise = new Exercise fetch 'level'

	btnDims.set current[1]
	btni.setLst range fetch 'n'
	btnj.setLst range fetch 'n'
	btnk.setLst range fetch 'n'

	if fetch('dims') in ['1D','2D']
		btnRotate.set 'no'
		store 'rotate', 'no'
	btnRotate.disabled fetch('dims') in ['1D','2D']
	btnn.set current[2]
	if fetch('dims') in ['1D','2D']
		vinkelX = 90
		vinkelY = 0
	if fetch('dims') == '3D'
		vinkelX = 45
		vinkelY = 45
	trace()

digit = (bool) -> if bool then 1 else 0
showStack = (level,cmd) -> tableAppend tabell, level + cmd, stack.join ' '
showError = (e) -> tableAppend tabell, e[0], e[1], '#FF0000'
gcd = (x, y) -> if y == 0 then x else gcd y, x % y

mousePressed = ->
	if 0 < mouseX < width and 0 < mouseY < height and fetch('dims') == '3D'
		lastX=mouseX
		lastY=mouseY
mouseDragged = ->
	if 0 < mouseX < width and 0 < mouseY < height and fetch('dims') == '3D'
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
		else if cmd == 'assert'
			if stack.pop() != stack.pop() then throw [level+cmd,'Assert failure']
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
	drawOne exercise.pattern_a, -200,16,words1,cubes1
	pop()

	push()
	drawOne exercise.pattern_b, 200,-16,words2,cubes2
	pop()

	#if frameCount < 100 then save "out-#{frameCount}.png"
	if saveCanvasCount > 0
		saveCanvas 'p5Forth3D', 'png'
		saveCanvasCount--

drawOne = (pattern, yOffset,vOffset,words,cubes) ->

	drawFigure = (s) =>
		s = _.max [int(s),5]
		u = int s/2
		if fetch('figure') == 'sphere' then sphere u,u,u else box s,s,s
	showAxes = =>
		if fetch('debug') == 'no' then return

		i0 = 0
		j0 = 0
		k0 = 0

		size = fetch('SIZE')
		n = fetch('n')
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

		if fetch('dims') >= '2D'
			push() # y
			translate 0,-y,0
			specularMaterial 0,255,0
			cylinder size/50,len
			pop()

		if fetch('dims') == '3D'
			push() # z
			translate -z,0,0
			rotateZ radians 90
			specularMaterial 0,0,255
			cylinder size/50,len
			pop()

		pop()

	drawCurrent = (radius,len) =>
		if fetch('debug') == 'no' then return

		i0 = fetch('i')
		j0 = fetch('j')
		k0 = fetch('k')
		if (i0==i and j0==j and k0==k) == false then return

		push() # x
		rotateX radians 90
		specularMaterial 255,0,0
		cylinder radius,len*1.05
		pop()

		push() # y
		specularMaterial 0,255,0
		cylinder radius,len*1.05
		pop()

		push() # z
		rotateZ radians 90
		specularMaterial 0,0,255
		cylinder radius,len*1.05
		pop()

	if fetch('fps') == 0 then return
	trace()

	if fetch('rotate') == 'yes'
		vinkelY += 1
		vinkelX += 0.5

	translate 0,yOffset,0

	rotateX radians vinkelY+vOffset
	rotateY radians vinkelX

	count = 0
	scaling = parseFloat fetch('size')
	size = fetch('SIZE')
	n = fetch('n')
	jvalues = if fetch('dims') == '1D' then range 1 else range n
	kvalues = if fetch('dims') <= '2D' then range 1 else range n
	index = 0
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

				if pattern[index] == '1'
					drawFigure scaling * size
					drawCurrent scaling * 2*size/10,scaling * size
					count++
				else
					if fetch('grid') == 'yes'
						drawFigure scaling * size/5
						drawCurrent scaling * 2*size/50, scaling * size/5
				pop()
				index++
	showAxes()

	if millis() > timestamp
		p3.innerHTML = "FPS: #{nf(frameRate(),0,1)}"
		timestamp = millis() + 1000

calcWords = (sourcecode) ->
	arr = sourcecode.replace(/\n/g,' ').split ' '
	arr = (item for item in arr when item.length > 0)
	arr.length

calcCubes = (sourcecode) ->
	n = fetch('n')
	jvalues = if fetch('dims') == '1D' then range 1 else range n
	kvalues = if fetch('dims') <= '2D' then range 1 else range n
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