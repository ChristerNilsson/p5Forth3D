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
sel3click = (sel) -> frameRate int sel.value
sel4click = (sel) ->

sel5click = (sel) -> trace()
sel6click = (sel) -> trace()
sel7click = (sel) -> trace()
sel8click = (sel) -> trace()

trace = ->
	tableClear()
	tableAppend tabell, 'command', 'stack'
	i = parseInt sel5.value
	j = parseInt sel6.value
	k = parseInt sel7.value
	t = parseInt sel8.value
	calc true

buildCommands = ->
	cmd0['i'] = => stack.push i
	cmd0['j'] = => stack.push j
	cmd0['k'] = => stack.push k
	cmd0['t'] = => stack.push t
	cmd0['drop'] = => stack.pop()

	cmd1['dup'] = (a) => stack = stack.concat [a,a]
	cmd1['not'] = (a) => stack.push digit a == 0
	cmd1['inv'] = (a) => stack.push 1 / a
	cmd1['chs'] = (a) => stack.push -a
	cmd1['sign'] = (a) => stack.push Math.sign a
	cmd1['abs'] = (a) => stack.push abs a
	cmd1['sqrt'] = (a) => stack.push sqrt a
	cmd1['rot'] = (a) => stack.push a
	cmd1['~'] = (a) => stack.push ~a
	cmd1['biti'] = (a) => stack.push a >> i & 1
	cmd1['bitj'] = (a) => stack.push a >> j & 1
	cmd1['bitk'] = (a) => stack.push a >> k & 1
	cmd1['bitij'] = (a) => stack = stack.concat [a >> i & 1, a >> j & 1]
	cmd1['bitik'] = (a) => stack = stack.concat [a >> i & 1, a >> k & 1]
	cmd1['bitjk'] = (a) => stack = stack.concat [a >> j & 1, a >> k & 1]
	cmd1['bitijk'] = (a) => stack = stack.concat [a >> i & 1, a >> j & 1, a >> k & 1]

	cmd2['swap'] = (a,b) => stack = stack.concat [a,b]
	cmd2['<'] = (a,b) => stack.push digit b < a
	cmd2['>'] = (a,b) => stack.push digit b > a
	cmd2['=='] = (a,b) => stack.push digit b == a
	cmd2['<='] = (a,b) => stack.push digit b <= a
	cmd2['>='] = (a,b) => stack.push digit b >= a
	cmd2['!='] = (a,b) => stack.push digit b != a
	cmd2['+'] = (a,b) => stack.push b + a
	cmd2['-'] = (a,b) => stack.push b - a
	cmd2['*'] = (a,b) => stack.push b * a
	cmd2['**'] = (a,b) => stack.push b ** a
	cmd2['/'] = (a,b) => stack.push b / a
	cmd2['//'] = (a,b) => stack.push b // a
	cmd2['%'] = (a,b) => stack.push b % a
	cmd2['%%'] = (a,b) => stack.push b %% a
	cmd2['gcd'] = (a,b) => stack.push gcd a,b
	cmd2['bit'] = (a,b) => stack.push b >> a & 1
	cmd2['&'] = (a,b) => stack.push b & a
	cmd2['|'] = (a,b) => stack.push b | a
	cmd2['^'] = (a,b) => stack.push b ^ a
	cmd2['>>'] = (a,b) =>	stack.push b >> a
	cmd2['<<'] = (a,b) => stack.push b << a
	cmd2['and'] = (a,b) => stack.push digit b!=0 and a!=0
	cmd2['or'] = (a,b) =>	stack.push digit b!=0 or a!=0
	cmd2['xor'] = (a,b) => stack.push digit b+a == 1

setup = ->
	c = createCanvas 500,500,WEBGL
	c.parent 'canvas'

	buildCommands()

	code = $ '#code'

	sel1 = $ '#sel1'
	sel2 = $ '#sel2'
	sel3 = $ '#sel3'
	sel4 = $ '#sel4'
	sel5 = $ '#sel5'
	sel6 = $ '#sel6'
	sel7 = $ '#sel7'
	sel8 = $ '#sel8'
	sel9 = $ '#sel9'

	tabell = $ '#tabell'

	p1 = $ '#p1'
	p2 = $ '#p2'
	p3 = $ '#p3'

	fillSelect sel1, ['free'].concat range 0, 360, 15 # x
	fillSelect sel2, ['free'].concat range 0, 360, 15 # y
	fillSelect sel3, range 1,26 # frameRate
	fillSelect sel4, range 25 # speed

	fillSelect sel5, range 10 #
	fillSelect sel6, range 10 # i
	fillSelect sel7, range 10 # j
	fillSelect sel8, range 10 # k
	fillSelect sel9, [1,2,4,8,16,32,64,128,256,512]

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
showStack = (level,cmd) -> tableAppend tabell, level + cmd, stack.join ' '
showError = (e) -> tableAppend tabell, e[0], e[1], '#FF0000'
mousePressed = -> if 0 < mouseX < width and 0 < mouseY < height then [lightX,lightY] = [mouseX,mouseY]
gcd = (x, y) -> if y == 0 then x else gcd y, x % y

evaluate = (traceFlag, line, level='') ->
	arr = line.split ' '
	for cmd in arr
		if cmd=='' then # do nothing
		else if words[cmd]?
			if level.indexOf('.'+cmd+'.') != -1 then throw [level+cmd,'Recursion not allowed']
			evaluate traceFlag, words[cmd], level + cmd + '.'
		else if cmd2[cmd]?
			if stack.length < 2 then throw [level+cmd,'Stack Underflow']
			cmd2[cmd] stack.pop(), stack.pop()
			if traceFlag then showStack level,cmd
		else if cmd1[cmd]?
			if stack.length < 1 then throw [level+cmd,'Stack Underflow']
			cmd1[cmd] if cmd=='rot' then stack.shift() else stack.pop()
			if traceFlag then showStack level,cmd
		else if cmd0[cmd]?
			cmd0[cmd]()
			if traceFlag then showStack level,cmd
		else
			nr = parseFloat cmd
			if _.isNumber(nr) and not _.isNaN nr
				stack.push nr
				if traceFlag then showStack level,cmd
			else
				throw [level+cmd,'Unknown Word']

calc = (traceFlag = false) ->
	stack = []
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
	if sel4.value == '0' then return
	bg 0.5

	if 0 < mouseX < width and 0 < mouseY < height
		locY = 1 - 2 * mouseY / height
		locX = 2 * mouseX / width - 1
	else
		locY = 1 - 2 * lightY / height
		locX = 2 * lightX / width - 1
	pointLight 255, 255, 255, locX,locY,0

	if sel1.value == 'free'
		yVinkel += sel4.value/500
		yVinkel %= TWO_PI
		rotateY yVinkel
	else rotateY radians sel1.value

	if sel2.value == 'free'
		xVinkel += sel4.value/500
		xVinkel %= TWO_PI
		rotateX xVinkel
	else rotateX radians sel2.value

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

tableAppend = (t, a, b, col='#C0C0C0') ->
	row = t.insertRow -1
	cell1 = row.insertCell -1
	cell2 = row.insertCell -1
	cell1.innerHTML = a
	cell2.innerHTML = b
	cell1.style.backgroundColor = '#808080'
	cell2.style.backgroundColor = col
	cell2.style.textAlign = 'right'