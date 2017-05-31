# p5Forth3D

Detta program kombinerar ForthHaiku med tredimensionella färgkuber.
För varje pixel i,j,k räknar ett Forthprogram ut om kuben ska vara med eller inte. Du skriver detta program.

Tag en titt på [ForthSalon](http://forthsalon.appspot.com/haiku-editor) innan du går vidare.

Notera att logiska värden har värdena 1 (sant) eller 0 (falskt). De går alltså att räkna med.

## Följande kommandon finns även i [Forth Haiku](http://forthsalon.appspot.com/word-list):

```javascript
dup swap
< > <= >= != ==
+ - * / %
& | ^ ~
and or not
abs sqrt
```

## Dessa kommandon finns bara i p5Forth3D:

```javascript
//  Heltalsdivision
%%  Modulo på negativa tal
rot Hämtar översta elementet på stacken
i   Hämtar i-koordinat 0..9
j   Hämtar j-koordinat 0..9
k   Hämtar k-koordinat 0..9
t   Hämtar frameCount
```

## Följande kommandon maskar bitar:

* bit
* biti,bitj,bitk Dessa hämtar i,j resp k själva
* bitij
* bitik
* bitjk
* bitijk

## Exempel:

```javascript
0 5 bit 1 ==
1 5 bit 0 ==
2 5 bit 1 ==
3 5 bit 0 ==

3 biti    <=>  i 3 bit
6 bitij   <=>  i 6 bit j 6 bit
9 bitijk  <=>  i 9 bit j 9 bit k 9 bit
```

## Dessutom kan nya ord skapas med :;

```javascript
: sq dup * ;
: dist sq swap sq + sqrt ;

6 sq 36 ==
3 4 dist 5 ==
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

* Ändringar i editorn slår igenom direkt.
* Nedre högra delen kan användas för att felsöka programmet. i,j,k och t väljs och man ser sedan hur stacken förändras. Sista raden bör innehålla ett enda värde. Om detta är noll ritas kuben ej ut.
* Du kan använda olika belysningsplaceringar med musen. Klicka för den du placering du vill ha.
* Sätt speed=0 om programmet känns segt.
* x=free innebär att kuben roterar vänster till höger
* y=free innebär att kuben roterar uppifrån och ner.
* Övriga värden för x och innebär fryst rotation i en viss vinkel.
