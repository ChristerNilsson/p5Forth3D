# p5Forth3D

Detta program kombinerar ForthHaiku med tredimensionella färgkuber.
För varje pixel i,j,k räknar ett Forthprogram ut om kuben ska vara med eller inte. Du skriver detta program.

Tag en titt på [ForthSalon](http://forthsalon.appspot.com/haiku-editor) innan du går vidare. Förutom att ForthSalon är 2D, kan man där ange färgen på varje pixel individuellt. Med p5Forth3D kan man inte styra över färgen.

Notera att logiska värden har värdena 1 (sant) eller 0 (falskt). De går alltså att räkna med.

## Följande kommandon är tillgängliga

```coffeescript
# Ingen operand
i j k
t
drop

# En operand
not chs inv abs sqrt ~ dup rot sign
biti bitj bitk bitij bitik bitjk bitijk

# Två operander
swap
+ - * ** / // % %%
< > <= >= != ==
& | ^ >> << bit
and or xor
```

```coffeescript
1 not    0  ==
0 not    1  ==

3 chs    -3  ==
2 inv    0.5  ==
-3 abs   3  ==
9 sqrt   3  ==
7 ~     -8  ==
-8 sign -1  ==
7 sign  1  ==
0 sign  0  ==

2 3 +    5  ==
2 3 -   -1  ==
2 3 *    6  ==
2 3 **   8  ==
1 2 /    0.5  ==
3 2 //   1  ==
7 2 %    1  ==
-7 2 %%  1  ==

2 3 <    1  ==
2 3 >    0  ==
2 3 <=   1  ==
2 3 >=   0  ==
2 3 !=   1  ==
2 3 ==   0  ==

7 12 &   4  ==
7 12 |  15  ==
7 12 ^  11  ==
7 2 >>  1   ==
2 3 <<  16  ==
0 5 bit  1  ==
1 5 bit  0  ==
2 5 bit  1  ==
3 5 bit  0  ==

0 0 and  0  ==
0 1 and  0  ==
1 0 and  0  ==
1 1 and  1  ==

0 0 or   0  ==
0 1 or   1  ==
1 0 or   1  ==
1 1 or   1  ==

0 0 xor  0  ==
0 1 xor  1  ==
1 0 xor  1  ==
1 1 xor  0  ==
```

## Dessa kommandon finns bara i p5Forth3D:

```coffeescript
i   Hämtar i-koordinat 0..9
j   Hämtar j-koordinat 0..9
k   Hämtar k-koordinat 0..9
t   Hämtar frameCount  0..
rot Hämtar översta elementet på stacken
//  Heltalsdivision
%%  Modulo på negativa tal
bit
biti bitj bitk
bitij bitik bitjk
bitijk
```

## Följande kommandon maskar bitar:

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

## Dessutom kan nya ord skapas med : och ;

```coffeescript
: sq dup * ;
: dist sq swap sq + sqrt ;

6 sq     36  ==
3 4 dist  5  ==

12 5 dist

ger följande ögonblicksbilder av stacken:

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
Tag bort ett ord så här:
```coffeescript
: sq ;
```

## Kommandon i [Forth Haiku](http://forthsalon.appspot.com/word-list)

## Övningar
[Exempel](https://christernilsson.github.io/p5Dojo/ForthHaiku3D.html)

## Koordinater

* Svarta hörnet motsvarar origo = 0,0,0
* Vita hörnet motsvarar 9,9,9
* röd axel motsvarar i
* grön axel motsvarar j
* blå axel motsvarar k

## Utritning

* Om editorn känns seg, dra ner på fps till 75% av maximal FPS.
* Sätt speed=0 för att stänga av omritning helt.
* Ändringar i editorn ritas ut direkt om speed >= 1.
* Du kan använda olika belysningsplaceringar med musen. Klicka för den du placering du vill ha.
* x = free innebär att kuben roterar vänster till höger
* y = free innebär att kuben roterar uppifrån och ner.
* Övriga värden för x och y innebär fryst rotation i en viss vinkel.

## Felsökning

Nedre högra delen kan användas för att felsöka ditt Forth-program.

* Välj i,j,k samt t och se hur beräkningen sker, kommando för kommando.
* Operatorerna arbetar på den högra änden av stacken.
* Sista raden bör innehålla ett enda värde. Om detta ej är noll ritas kuben ut.
* Klicka på något värde för att uppdatera tabellen med kommandon och ögonblicksbilder av stacken.