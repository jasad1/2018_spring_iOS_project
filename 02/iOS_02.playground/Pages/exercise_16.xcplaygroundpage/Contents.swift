import Foundation

// Feladat 16: Hozzunk létre egy Additive protocolt ami elvárja hogy egy típuson értelmezve legyen az összeadás művelet. A complex osztály komformáljon ehhez a protocolhoz is!

protocol Additive {
    static func +(lhs: Self, rhs: Self) -> Self
}

struct Complex: Equatable, Additive {
    var real: Double
    var imaginary: Double
    
    static func ==(lhs: Complex, rhs: Complex) -> Bool {
        return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
    }
    
    static func +(lhs: Complex, rhs: Complex) -> Complex {
        return Complex(real: lhs.real + rhs.real,
                       imaginary: lhs.imaginary + rhs.imaginary)
    }
}

let a = Complex(real: 1, imaginary: 2)
let b = Complex(real: 1, imaginary: 2)
let c = Complex(real: 2, imaginary: 4)

if a == b {
    print("🐽")
}

if (a + b) == c {
    print("🐽")
}
