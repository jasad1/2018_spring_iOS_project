import Foundation

// Feladat 3: Hibás a kód. Miért?

struct Kismalac {
    private var valami = "röf röf röf"
    
    func mondjValamitKismalac() -> String {
        return valami
    }
    
    mutating func valamiMastMondjKismalac(valamiMas mas: String) {
        self.valami = mas
    }
}

var 🐖 = Kismalac()
🐖.valamiMastMondjKismalac(valamiMas: "töf töf töf")
print(🐖.mondjValamitKismalac())
