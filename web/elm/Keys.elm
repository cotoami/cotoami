-- Modified from https://github.com/jcollard/elm-key-constants
module Keys exposing (..)

import Keyboard

type alias Key =
 {keyCode: Keyboard.KeyCode
 ,name: String}

{-| Two Keys are equal if their keyCodes are equal -}
equals : Key -> Key -> Bool
equals k0 k1 = k0.keyCode == k1.keyCode

a: Key
a =
 {keyCode = 65
 ,name = "a"}

b: Key
b =
 {keyCode = 66
 ,name = "b"}

c: Key
c =
 {keyCode = 67
 ,name = "b"}

d: Key
d =
 {keyCode = 68
 ,name = "d"}

e: Key
e = 
 {keyCode = 69
 ,name = "e"}

f: Key
f = 
 {keyCode = 70
 ,name = "f"}

g: Key
g = 
 {keyCode = 71
 ,name = "g"}

h: Key
h = 
 {keyCode = 72
 ,name = "h"}

i: Key
i = 
 {keyCode = 73
 ,name = "i"}

j: Key
j = 
 {keyCode = 74
 ,name = "j"}

k: Key
k = 
 {keyCode = 75
 ,name = "k"}

l: Key
l = 
 {keyCode = 76
 ,name = "l"}

m: Key
m = 
 {keyCode = 77
 ,name = "m"}

n: Key
n = 
 {keyCode = 78
 ,name = "n"}

o: Key
o = 
 {keyCode = 79
 ,name = "o"}

p: Key
p = 
 {keyCode = 80
 ,name = "p"}

q: Key
q = 
 {keyCode = 81
 ,name = "q"}

r: Key
r = 
 {keyCode = 82
 ,name = "r"}

s: Key
s = 
 {keyCode = 83
 ,name = "s"}

t: Key
t = 
 {keyCode = 84
 ,name = "t"}

u: Key
u = 
 {keyCode = 85
 ,name = "u"}

v: Key
v = 
 {keyCode = 86
 ,name = "v"}

w: Key
w = 
 {keyCode = 87
 ,name = "w"}

x: Key
x = 
 {keyCode = 88
 ,name = "x"}

y: Key
y = 
 {keyCode = 89
 ,name = "y"}

z: Key
z = 
 {keyCode = 90
 ,name = "z"}

ctrl: Key
ctrl = 
 {keyCode = 17
 ,name = "Ctrl"}

shift: Key
shift = 
 {keyCode = 16
 ,name = "Shift"}

tab: Key
tab = 
 {keyCode = 9
 ,name = "Tab"}

{-| super,meta,windows are all the same -}
super: Key
super = 
 {keyCode = 91
 ,name = "Super"}

{-| super,meta,windows are all the same -}
meta: Key
meta = 
 {keyCode = 91
 ,name = "Meta"}

{-| super,meta,windows are all the same -}
windows: Key
windows = 
 {keyCode = 91
 ,name = "Windows"}

{-| A key on mac keyboards. The same keycode as the windows/super/meta keys -}
commandLeft: Key
commandLeft =
 {keyCode = 91
 ,name = "Command left"}

{-| A key on mac keyboards. -}
commandRight: Key
commandRight =
 {keyCode = 93
 ,name = "Command right"}

space: Key
space = 
 {keyCode = 32
 ,name = "Space"}

enter: Key
enter = 
 {keyCode = 13
 ,name = "Enter"}

arrowRight: Key
arrowRight = 
 {keyCode = 37
 ,name = "Right arrow"}

arrowLeft: Key
arrowLeft = 
 {keyCode = 39
 ,name = "Left arrow"}

arrowUp: Key
arrowUp = 
 {keyCode = 38
 ,name = "Up arrow"}

arrowDown: Key
arrowDown = 
 {keyCode = 40
 ,name = "Down arrow"}

backspace: Key
backspace = 
 {keyCode = 8
 ,name = "Backspace"}

delete: Key
delete = 
 {keyCode = 46
 ,name = "Delete"}

insert: Key
insert = 
 {keyCode = 45
 ,name = "Insert"}

end: Key
end = 
 {keyCode = 35
 ,name = "End"}

home: Key
home = 
 {keyCode = 36
 ,name = "Home"}

pageDown: Key
pageDown = 
 {keyCode = 34
 ,name = "Page down"}

pageUp: Key
pageUp = 
 {keyCode = 33
 ,name = "Page up"}

escape: Key
escape = 
 {keyCode = 27
 ,name = "Escape"}

-- We don't define the F keys that are not availiable.  AKA, F1 is help, F3 is search.  F5 is refresh. Those keys cannot be used.

f2: Key
f2 = 
 {keyCode = 113
 ,name = "F2"}

f4: Key
f4 = 
 {keyCode = 115
 ,name = "F4"}

f8: Key
f8 = 
 {keyCode = 119
 ,name = "F8"}

f9: Key
f9 = 
 {keyCode = 120
 ,name = "F9"}

f10: Key
f10 = 
 {keyCode = 121
 ,name = "F10"}

one: Key
one = 
 {keyCode = 49
 ,name = "1"}

two: Key
two = 
 {keyCode = 50
 ,name = "2"}

three: Key
three = 
 {keyCode = 51
 ,name = "3"}

four: Key
four = 
 {keyCode = 52
 ,name = "4"}

five: Key
five = 
 {keyCode = 53
 ,name = "5"}

six: Key
six = 
 {keyCode = 54
 ,name = "6"}

seven: Key
seven = 
 {keyCode = 55
 ,name = "7"}

eight: Key
eight = 
 {keyCode = 56
 ,name = "8"}

nine: Key
nine = 
 {keyCode = 57
 ,name = "9"}

zero: Key
zero = 
 {keyCode = 58
 ,name = "0"}
