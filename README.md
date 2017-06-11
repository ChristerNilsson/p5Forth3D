# p5Forth3D

* This program combines Forth Salon with three-dimensional color cubes.
* For each pixel (i,j,k), a small forth code calculates if it should be visible or not.
* This code is written by you.

* Have a quick look at [Forth Salon](http://forthsalon.appspot.com/haiku-editor) before continuing.
* Forth Salon is 2D and you can set the color for each pixel individually.
* With p5Forth3D it is not possible to choose color.

* Please note, logical values (false,true) are (0,1).
* You can make arithmetical calculations with them.

## The following words are available

```coffeescript
# No operand
i j k
t
drop pop

# One operand
not chs inv abs sqrt ~ dup sign push
biti bitj bitk bitij bitik bitjk bitijk

# Two operands
swap
+ - * ** / // % %% gcd
< > <= >= <> =
& | ^ >> << bit
and or xor

# Three operands
rot -rot
```

```coffeescript
1 not    0  =
0 not    1  =

3 chs    -3  =
2 inv    0.5  =
-3 abs   3  =
9 sqrt   3  =
7 ~     -8  =
-8 sign -1  =
7 sign  1  =
0 sign  0  =

2 3 +    5  =
2 3 -   -1  =
2 3 *    6  =
2 3 **   8  =
1 2 /    0.5  =
3 2 //   1  =
7 2 %    1  =
-7 2 %%  1  =
12 15 gcd 3 =

2 3 <    1  =
2 3 >    0  =
2 3 <=   1  =
2 3 >=   0  =
2 3 <>   1  =
2 3 =  0  =

7 12 &   4  =
7 12 |  15  =
7 12 ^  11  =
7 2 >>  1   =
2 3 <<  16  =
0 5 bit  1  =
1 5 bit  0  =
2 5 bit  1  =
3 5 bit  0  =

0 0 and  0  =
0 1 and  0  =
1 0 and  0  =
1 1 and  1  =

0 0 or   0  =
0 1 or   1  =
1 0 or   1  =
1 1 or   1  =

0 0 xor  0  =
0 1 xor  1  =
1 0 xor  1  =
1 1 xor  0  =

rot   Fetches the third element of the stack
-rot  The opposite

```

## This words are only defined in p5Forth3D:

```coffeescript
i   coordinate 0 .. n-1
j   coordinate 0 .. n-1
k   coordinate 0 .. n-1
t   frameCount 0..
//  integer division
%%  negative number modulo
bit
biti bitj bitk
bitij bitik bitjk
bitijk
```

## Words masking bits:

```coffeescript
bit
biti bitj bitk
bitij bitik bitjk
bitijk
```
```coffeescript
: bit swap >> 1 & ;
: biti i swap bit ;
: bitj j swap bit ;
: bitk k swap bit ;
: bitij dup biti swap bitj ;
: bitijk dup bitij swap bitk ;
```

## New words are created with :

```coffeescript
: sq dup * ;
: dist sq swap sq + sqrt ;

6 sq     36  =
3 4 dist  5  =

12 5 dist

gives this stack snapshot:

command        stack
12                12
5               12 5
dist.sq.dup   12 5 5
dist.sq.*      12 25
dist.swap      25 12
dist.sq.dup 25 12 12
dist.sq.*     25 144
dist.+           169
dist.sqrt         13
```
Remove a word:
```coffeescript
: sq ;
```

## Words in [Forth Salon](http://forthsalon.appspot.com/word-list)

## Exercises

```coffeescript
513 bitijk and and
```
Bit 0 and 9 are visible for all three dimensions.
Please note, the binary number 1000000001 is 513 in decimal.
The eight corners shows clean colors. The origin is black.

[Examples](https://christernilsson.github.io/p5Forth3D/examples.html)

## Coordinates

* The black corner is the origin = 0,0,0
* The white corner is 9,9,9 or n-1,n-1,n-1
* i is the red axis
* j is the green axis
* k is the blue axis

## Drawing

* If the program is slow, reduce fps or n.
* Set fps to 0 to stop drawing.
* You can place the light with the mouse. Click to remember the position.

## Debugging

The right lower part can be used to debug your forth code

* Select i,j,k and t and inspect the calculation, word by word.
* The words works on the right end of the stack.
* The last line should contain exactly one value. If this is a 1, a sphere or box is drawn for this pixel.

## Thanks!

* [p5js](https://p5js.org)
* [Coffeescript](http://coffeescript.org)
* [Forth Haiku Salon](http://forthsalon.appspot.com)