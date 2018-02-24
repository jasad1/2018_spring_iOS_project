import Foundation

// Feladat 14: Ebben a kódban valahol memória kezelési gondok vannak. Találd meg mi az!

class Kismalac {
    private(set) var etel: Int = 0
    
    var evesUtan: (() -> Void)?
    
    func egyelKismalac() {
        guard etel > 0 else { return }
        etel -= 1
        evesUtan?()
    }
    
    func ittVanEtelKismalac(etel: Int) {
        self.etel += etel
    }
}

let 🐖 = Kismalac()

🐖.ittVanEtelKismalac(etel: 2)
🐖.egyelKismalac()
🐖.evesUtan = { [unowned 🐖] in
    if 🐖.etel == 0 {
        🐖.ittVanEtelKismalac(etel: 1)
    }
}
