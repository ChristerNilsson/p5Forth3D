# p5Forth3D

Detta program kombinerar ForthHaiku med tredimensionella färgkuber.
För varje pixel i,j,k räknar ett Forthprogram ut om kuben ska vara med eller inte. Du skriver detta program.

Tag en titt på [ForthSalon](http://forthsalon.appspot.com/haiku-editor) innan du går vidare.

Notera att logiska värden har värdena 1 (sant) eller 0 (falskt). De går alltså att räkna med.

## Följande kommandon finns även i [Forth Haiku](http://forthsalon.appspot.com/word-list):

```coffeescript
dup swap
+ - * / %
< > <= >= != ==
& | ^ ~
and or not
abs sqrt
```
```coffeescript
2 3 +    5  ==
2 3 *    6  ==
2 3 -   -1  ==

2 3 ==   0  ==
2 3 !=   1  ==
2 3 >    0  ==

7 12 |  15  ==
7 12 &   4  ==
7 12 ^  11  ==

1 0 and  0  ==
1 0 or   1  ==
1 not    0  ==
0 not    1  ==

-3 abs   3  ==
9 sqrt   3  ==
```

## Dessutom kan nya ord skapas med : och ; som brukligt är i Forth

```coffeescript
: sq dup * ;
: dist sq swap sq + sqrt ;

6 sq     36  ==
3 4 dist  5  ==

12 5 dist

ger följande stacktrace:

command     stack
12          [12]
5           [12,5]
dist.sq.dup [12,5,5]
dist.sq.*   [12,25]
dist.swap   [25,12]
dist.sq.dup [25,12,12]
dist.sq.*   [25,144]
dist.+      [169]
dist.sqrt   [13]
```
Tag bort ett ord så här:
```coffeescript
: sq ;
```

## Dessa kommandon finns bara i p5Forth3D:

```coffeescript
//  Heltalsdivision
%%  Modulo på negativa tal
rot Hämtar översta elementet på stacken
i   Hämtar i-koordinat 0..9
j   Hämtar j-koordinat 0..9
k   Hämtar k-koordinat 0..9
t   Hämtar frameCount  0..
```

## Följande kommandon maskar bitar:

```coffeescript
bit
biti bitj bitk
bitij bitik bitjk
bitijk
```

## Exempel:

```coffeescript
0 5 bit  1  ==
1 5 bit  0  ==
2 5 bit  1  ==
3 5 bit  0  ==

: bit swap >> 1 & ;
: biti i swap bit ;
: bitj j swap bit ;
: bitk k swap bit ;
: bitij dup biti swap bitj ;
: bitijk dup bitij swap bitk ;
```

## Övningar
[Exempel](https://christernilsson.github.io/p5Dojo/ForthHaiku3D.html)

## Koordinater

* Svarta hörnet motsvarar origo = 0,0,0
* Vita hörnet motsvarar 9,9,9
* röd axel motsvarar i
* grön axel motsvarar j
* blå axel motsvarar k

## Övrig information

* Ändringar i editorn ritas ut direkt om speed >= 1.
* Nedre högra delen kan användas för att felsöka programmet.
 * i,j,k och t väljs och man ser sedan hur stacken förändras.
 * Sista raden bör innehålla ett enda värde.
 * Om detta är noll ritas kuben ej ut.
 * Klicka på något värde för att uppdatera tabellen med kommandon och ögonblicksbilder av stacken.
* Du kan använda olika belysningsplaceringar med musen. Klicka för den du placering du vill ha.
* Sätt speed=0 för att stänga av omritning.
* x=free innebär att kuben roterar vänster till höger
* y=free innebär att kuben roterar uppifrån och ner.
* Övriga värden för x och y innebär fryst rotation i en viss vinkel.