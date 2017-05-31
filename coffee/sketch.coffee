N = 10
SIZE = 250/N

pg = Array N*N*N
lightX = 0
lightY = 0
commands = {}
stack = []
i = 0
j = 0
k = 0
t = 0
frameRates = []
frameRateSum = 0

words = {}

fillSelect = (sel, arr) ->
	sel.empty()
	for key in arr
		sel.append($("<option>").attr('value', key).text(key))

sel1click = (sel) -> print sel.value
sel2click = (sel) -> print sel.value
sel4click = (sel) -> print sel.value

sel5click = (sel) -> trace()
sel6click = (sel) -> trace()
sel7click = (sel) -> trace()
sel8click = (sel) -> trace()

trace = (sel) ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = parseInt(sel5.value)
	j = parseInt(sel6.value)
	k = parseInt(sel7.value)
	t = parseInt(sel8.value)
	calc true

buildCommands = =>
	commands = {}
	commands['dup'] = () => stack.push _.last stack
	commands['swap'] = () =>
		n = stack.length - 1
		[stack[n-1],stack[n]] = [stack[n],stack[n-1]]
	commands['rot'] = () => stack.push stack.shift()
	commands['i'] = () => stack.push i
	commands['j'] = () => stack.push j
	commands['k'] = () => stack.push k
	commands['t'] = () => stack.push t
	commands['<'] = () => stack.push digit stack.pop() > stack.pop()
	commands['>'] = () => stack.push digit stack.pop() < stack.pop()
	commands['=='] = () => stack.push digit stack.pop() == stack.pop()
	commands['<='] = () => stack.push digit stack.pop() >= stack.pop()
	commands['>='] = () => stack.push digit stack.pop() <= stack.pop()
	commands['!='] = () => stack.push digit stack.pop() != stack.pop()
	commands['+'] = () => stack.push stack.pop() + stack.pop()
	commands['-'] = () => stack.push -stack.pop() + stack.pop()
	commands['*'] = () => stack.push stack.pop() * stack.pop()
	commands['/'] = () =>
		a = stack.pop()
		stack.push stack.pop() / a
	commands['//'] = () =>
		a = stack.pop()
		stack.push stack.pop() // a
	commands['%'] = () =>
		a = stack.pop()
		stack.push stack.pop() % a
	commands['%%'] = () =>
		a = stack.pop()
		stack.push stack.pop() %% a
	commands['bit'] = () => stack.push stack.pop() >> stack.pop() & 1
	commands['biti'] = () => stack.push stack.pop() >> i & 1
	commands['bitj'] = () => stack.push stack.pop() >> j & 1
	commands['bitk'] = () => stack.push stack.pop() >> k & 1
	commands['bitij'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> j & 1]
	commands['bitik'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> k & 1]
	commands['bitjk'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> j & 1, bits >> k & 1]
	commands['bitijk'] = () =>
		bits = stack.pop()
		stack = stack.concat [bits >> i & 1, bits >> j & 1, bits >> k & 1]
	commands['&'] = () => stack.push stack.pop() & stack.pop()
	commands['|'] = () => stack.push stack.pop() | stack.pop()
	commands['^'] = () => stack.push stack.pop() ^ stack.pop()
	commands['~'] = () => stack.push ~stack.pop()
	commands['and'] = () =>
		[a,b] = [stack.pop(),stack.pop()]
		stack.push digit a!=0 and b!=0
	commands['or'] = () =>
		[a,b] = [stack.pop(),stack.pop()]
		stack.push digit a!=0 or b!=0
	commands['xor'] = () =>
		a = digit stack.pop() != 0
		b = digit stack.pop() != 0
		stack.push digit a+b == 1
	commands['not'] = () => stack.push digit stack.pop() == 0
	commands['abs'] = () => stack.push abs stack.pop()
	commands['sqrt'] = () => stack.push sqrt stack.pop()

setup = ->
	c = createCanvas 500,500,WEBGL
	c.parent 'canvas'

	buildCommands()

	code = $('#code')

	sel1 = $('#sel1')
	sel2 = $('#sel2')
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

	fillSelect sel4, range 25 # speed
	fillSelect sel5, range 10 #
	fillSelect sel6, range 10 # i
	fillSelect sel7, range 10 # j
	fillSelect sel8, range 10 # k

	sel1.val("free").change()
	sel2.val("free").change()
	sel4.val("1").change()

	sel5.val("0").change()
	sel6.val("0").change()
	sel7.val("0").change()
	sel8.val("0").change()

	trace()

	f = 255/(N-1)
	for i in range N
		for j in range N
			for k in range N
				index = N*N*k+N*j+i
				pg[index] = createGraphics 1, 1
				pg[index].background f*i, f*j, f*k

digit = (bool) -> if bool then 1 else 0

evaluate = (trace, line, level='') ->
	arr = line.split ' '
	for cmd in arr
		if cmd==''
		else if commands[cmd]?
			commands[cmd]()
			if trace then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'
		else if words[cmd]?
			evaluate true, words[cmd],level + cmd + '.'
		else
			stack.push parseFloat cmd
			if trace then tableAppend tabell, level + cmd, '[' + stack.join(',') + ']'

calc = (trace=false) ->
	stack = []
	lines = code.value.split "\n"
	for line in lines
		if line.indexOf(':')==0
			arr = line.split ' '
			words[arr[1]] = arr[2..-2].join(' ')
		else
			evaluate trace,line
	0 != _.last stack

mousePressed = ->
	if 0<mouseX<width then lightX = mouseX
	if 0<mouseY<height then lightY = mouseY

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
		rotateY sel4.value * frameCount/250
	else
		rotateY radians sel1.value

	if sel2.value == 'free'
		rotateX sel4.value * frameCount/500
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

	p1.innerHTML = 'Words: ' + code.value.replace(/\n/,' ').split(' ').length
	p2.innerHTML = 'Cubes: ' + count
	fr = frameRate()
	frameRateSum += fr
	frameRates.push fr
	if frameRates.length > 200 then frameRateSum -= frameRates.shift()
	p3.innerHTML = 'FPS: ' + int frameRateSum/frameRates.length

tableClear = -> $("#tabell tr").remove()

tableAppend = (t, a, b) ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = a
	cell2.innerHTML = b
