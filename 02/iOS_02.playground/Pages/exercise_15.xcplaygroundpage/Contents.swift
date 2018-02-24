import Foundation

// Feladat 15: Oldjuk meg, hogy a Complex osztály konformáljon az Equatable protocolhoz!

struct Complex : Equatable {
    var real: Double
    var imaginary: Double
    
    static func ==(lhs: Complex, rhs: Complex) -> Bool {
        return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
    }
}

let a = Complex(real: 1, imaginary: 2)
let b = Complex(real: 2, imaginary: 3)
let c = Complex(real: 1, imaginary: 2)

if a == b {
    print("🐽")
}

if a == c {
    print("🐽")
}

if b == c {
    print("🐽")
}
