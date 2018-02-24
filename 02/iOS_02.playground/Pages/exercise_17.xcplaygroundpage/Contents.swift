import Foundation

// Feladat 17: Adjuk össze 1-től 100-ig a természetes számok négyzetei közül a páratlanokat

let arr = Array(1...100)

let sum = arr.map({ $0 * $0 })
             .filter({ $0 % 2 == 1 })
             .reduce(0, { $0 + $1 })

if sum == 166650 {
    print("🐽")
}
