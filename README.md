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