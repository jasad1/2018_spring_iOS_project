import Foundation

// Feladat 4: Egyetlen kulcsszó lecserélésével érd el hogy a kód leforduljon és az if is teljesüljön

class A {
    var value: Int = 0
}

let a = A()

let a2 = a

a2.value = 3

if a.value == 3 && a2.value == 3 {
    print("🐽")
}

