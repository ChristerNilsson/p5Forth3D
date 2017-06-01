N = 10
SIZE = 250/N

pg = Array N*N*N
lightX = 0
lightY = 0

cmd0 = {}
cmd1 = {}
cmd2 = {}

stack = []
i = 0
j = 0
k = 0
t = 0
xVinkel = 0 # radians
yVinkel = 0 # radians
timestamp = 0

words = {}

fillSelect = (sel, arr) ->
	sel.empty()
	for key in arr
		sel.append($("<option>").attr('value', key).text(key))

sel1click = (sel) ->
sel2click = (sel) ->
sel3click = (sel) ->
	print sel.value
	frameRate int sel.value
sel4click = (sel) ->

sel5click = (sel) -> trace()
sel6click = (sel) -> trace()
sel7click = (sel) -> trace()
sel8click = (sel) -> trace()

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = parseInt(sel5.value)
	j = parseInt(sel6.value)
	k = parseInt(sel7.value)
	t = parseInt(sel8.value)
	calc true

buildCommands = =>
	cmd0 = {}
	cmd1 = {}
	cmd2 = {}

	cmd0['i'] = () => stack.push i
	cmd0['j'] = () => stack.push j
	cmd0['k'] = () => stack.push k
	cmd0['t'] = () => stack.push t

	cmd1['dup'] = () => stack.push _.last stack
	cmd1['not'] = () => stack.push digit stack.pop() == 0
	cmd1['inv'] = () => stack.push 1 / stack.pop()
	cmd1['abs'] = () => stack.push abs stack.pop()
	cmd1['sqrt'] = () => stack.push sqrt stack.pop()
	cmd1['rot'] = () => stack.push stack.shift()
	cmd1['~'] = () => stack.push ~stack.pop()
	cmd1['biti'] = () => stack.push stack.pop() >> i & 1
	cmd1['bitj'] = () => stack.push stack.pop() >> j & 1
	cmd1['bitk'] = () => stack.push stack.pop() >> k & 1
	cmd1['bitij'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> j & 1]
	cmd1['bitik'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> k & 1]
	cmd1['bitjk'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> j & 1, bits >> k & 1]
	cmd1['bitijk'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> j & 1, bits >> k & 1]

	cmd2['swap'] = () =>
		n = stack.length - 1
		[stack[n-1],stack[n]] = [stack[n],stack[n-1]]
	cmd2['<'] = () => stack.push digit stack.pop() > stack.pop()
	cmd2['>'] = () => stack.push digit stack.pop() < stack.pop()
	cmd2['=='] = () => stack.push digit stack.pop() == stack.pop()
	cmd2['<='] = () => stack.push digit stack.pop() >= stack.pop()
	cmd2['>='] = () => stack.push digit stack.pop() <= stack.pop()
	cmd2['!='] = () => stack.push digit stack.pop() != stack.pop()
	cmd2['+'] = () => stack.push stack.pop() + stack.pop()
	cmd2['-'] = () => stack.push -stack.pop() + stack.pop()
	cmd2['*'] = () => stack.push stack.pop() * stack.pop()
	cmd2['/'] = () =>
		a = stack.pop()
		stack.push stack.pop() / a
	cmd2['//'] = () =>
		a = stack.pop()
		stack.push stack.pop() // a
	cmd2['%'] = () =>
		a = stack.pop()
		stack.push stack.pop() % a
	cmd2['%%'] = () =>
		a = stack.pop()
		stack.push stack.pop() %% a
	cmd2['bit'] = () => stack.push stack.pop() >> stack.pop() & 1
	cmd2['&'] = () => stack.push stack.pop() & stack.pop()
	cmd2['|'] = () => stack.push stack.pop() | stack.pop()
	cmd2['^'] = () => stack.push stack.pop() ^ stack.pop()
	cmd2['>>'] = () =>
		a = stack.pop()
		stack.push stack.pop() >> a
	cmd2['<<'] = () =>
		a = stack.pop()
		stack.push stack.pop() << a
	cmd2['and'] = () =>
		[a,b] = [stack.pop(),stack.pop()]
		stack.push digit a!=0 and b!=0
	cmd2['or'] = () =>
		[a,b] = [stack.pop(),stack.pop()]
		stack.push digit a!=0 or b!=0
	cmd2['xor'] = () =>
		a = digit stack.pop() != 0
		b = digit stack.pop() != 0
		stack.push digit a+b == 1

setup = ->
	c = createCanvas 500,500,WEBGL
	c.parent 'canvas'

	buildCommands()

	code = $('#code')

	sel1 = $('#sel1')
	sel2 = $('#sel2')
	sel3 = $('#sel3')
	sel4 = $('#sel4')
	sel5 = $('#sel5')
	sel6 = $('#sel6')
	sel7 = $('#sel7')
	sel8 = $('#sel8')

	tabell = $('#tabell')

	p1 = $('#p1')
	p2 = $('#p2')
	p3 = $('#p3')

	fillSelect sel1, ['free'].concat range 0, 360, 15 # x
	fillSelect sel2, ['free'].concat range 0, 360, 15 # y
	fillSelect sel3, range 1,26 # frameRate
	fillSelect sel4, range 25 # speed

	fillSelect sel5, range 10 #
	fillSelect sel6, range 10 # i
	fillSelect sel7, range 10 # j
	fillSelect sel8, range 10 # k

	frameRate 10

	sel1.val("free").change() # x
	sel2.val("free").change() # y
	sel3.val("10").change() # fps
	sel4.val("10").change() # speed

	sel5.val("0").change() # i
	sel6.val("0").change() # j
	sel7.val("0").change() # k
	sel8.val("0").change() # t

	trace()

	f = 255/(N-1)
	for i in range N
		for j in range N
			for k in range N
				index = N*N*k+N*j+i
				pg[index] = createGraphics 1, 1
				pg[index].background f*i, f*j, f*k

digit = (bool) -> if bool then 1 else 0

evaluate = (traceFlag, line, level='') ->
	arr = line.split ' '
	for cmd in arr
		if cmd==''
			# do nothing
		else if words[cmd]?
			evaluate traceFlag, words[cmd],level + cmd + '.'
		else if cmd2[cmd]?
			if stack.length < 2 then throw [level+cmd,'Stack Underflow']
			cmd2[cmd]()
			if traceFlag==true then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'
		else if cmd1[cmd]?
			if stack.length < 1 then throw [level+cmd,'Stack Underflow']
			cmd1[cmd]()
			if traceFlag==true then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'
		else if cmd0[cmd]?
			cmd0[cmd]()
			if traceFlag==true then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'
		else
			nr = parseFloat cmd
			if _.isNumber(nr) and not _.isNaN nr
				stack.push nr
				if traceFlag==true then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'
			else
				throw [level+cmd,'Unknown symbol']
calc = (traceFlag = false) ->
	stack = []
	lines = code.value.split "\n"
	try
		for line in lines
			if line.indexOf(':')==0
				arr = line.split ' '
				if arr.length == 3 and arr[2] == ';'
					delete words[arr[1]]
				else
					words[arr[1]] = arr[2..-2].join(' ')
			else
				evaluate traceFlag, line
		0 != _.last stack
	catch e
		if traceFlag==true
			[cmd, message] = e
			tableAppend tabell, cmd, message

mousePressed = ->
	if 0 < mouseX < width then lightX = mouseX
	if 0 < mouseY < height then lightY = mouseY

draw = ->
	if sel4.value == '0' then return
	bg 0.5

	if 0 < mouseX < width and 0 < mouseY < height
		locY = (0.5 - mouseY / height) * 2
		locX = (mouseX / width  - 0.5) * 2
	else
		locY = (0.5 - lightY / height) * 2
		locX = (lightX / width  - 0.5) * 2
	pointLight 255, 255, 255, locX,locY,0

	if sel1.value == 'free'
		yVinkel += sel4.value/500
		yVinkel %= TWO_PI
		rotateY yVinkel
	else
		rotateY radians sel1.value

	if sel2.value == 'free'
		xVinkel += sel4.value/500
		xVinkel %= TWO_PI
		rotateX xVinkel
	else
		rotateX radians sel2.value

	t = frameCount
	count = 0
	for i in range N
		for j in range N
			for k in range N
				push()
				translate SIZE*(0.5+i-N/2),SIZE*(0.5+j-N/2),SIZE*(0.5+k-N/2)
				if calc()
					index = N*N*k+N*j+i
					texture pg[index]
					box SIZE,SIZE,SIZE
					count++
				else
					texture pg[N*N*N-1]
					box 2,2,2
				pop()

	p1.innerHTML = 'Words: ' + code.value.replace(/\n/g,' ').split(' ').length
	p2.innerHTML = 'Cubes: ' + count
	if millis() > timestamp
		p3.innerHTML = 'FPS: ' + int frameRate()
		timestamp = millis() + 1000

tableClear = -> $("#tabell tr").remove()

tableAppend = (t, a, b) ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = a
	cell2.innerHTML = b
