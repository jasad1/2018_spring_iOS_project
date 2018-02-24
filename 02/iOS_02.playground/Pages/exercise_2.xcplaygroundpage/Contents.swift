import Foundation

// Feladat 2: Szemantikailag valami nincs rendben szegény Kismalaccal. Mi az?

struct Kismalac {
    private let valami = "röf röf röf"
    
    func mondjValamitKismalac() -> String {
        return valami
    }
}


let 🐖 = Kismalac()

print(🐖.mondjValamitKismalac())
