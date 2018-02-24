import Foundation

// Feladat 9: Javitsd meg a Kismalac osztályt, hogy véletlenül se termináljon!

struct Kismalac {
    private var etel: String?
    
    mutating func mitEszelKismalac() -> String? {
        defer {
            etel = nil
        }
        return etel
    }
    
    mutating func ittVanEtelKismalac(etel: String) {
        self.etel = etel
    }
}

var 🐖 = Kismalac()

🐖.ittVanEtelKismalac(etel: "Alma")
🐖.mitEszelKismalac()
🐖.ittVanEtelKismalac(etel: "Kukorica")
🐖.mitEszelKismalac()
🐖.mitEszelKismalac()
