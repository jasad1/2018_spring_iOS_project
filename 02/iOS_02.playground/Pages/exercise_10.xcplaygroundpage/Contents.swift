import Foundation

// Feladat 10: Old meg, hogy a kismalacnak legyen egy olyan mezője ami mindig a teljes nevét adja vissza!

struct Kismalac {
    var vezeteknev: String = "Hajnal"
    var keresztnev: String = "József"
    
    // Ide Írj
    var teljesnev: String {
        return vezeteknev + " " + keresztnev
    }
    // Idáig
}

var 🐖 = Kismalac()
print("A kismalac teljes neve: \(🐖.teljesnev)")

if 🐖.teljesnev == "Hajnal József" {
    print("🐽")
}

🐖.keresztnev = "János"
if 🐖.teljesnev == "Hajnal János" {
    print("🐽")
}

