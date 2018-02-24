import Foundation

// Feladat 11: A Kismalacnak sosem lehet tobb mint 5 repaja illetve sosem lehet kevessebb mint 1 repaja

struct Kismalac {
    private var repakSzama: Int = 1 {
        didSet {
            if repakSzama < 1 {
                repakSzama = 1
            } else if repakSzama > 5 {
                repakSzama = 5
            }
        }
    }
    
    func hanyRepadVanKismalac() -> Int {
        return repakSzama
    }
    
    mutating func ittVanRepaKismalac(repak: Int) {
        repakSzama = repak
    }
}


var 🐖 = Kismalac()

🐖.ittVanRepaKismalac(repak: 3)
guard 🐖.hanyRepadVanKismalac() == 3 else {
    fatalError()
}

🐖.ittVanRepaKismalac(repak: 6)
guard 🐖.hanyRepadVanKismalac() == 5 else {
    fatalError("Répa overflow!")
}

🐖.ittVanRepaKismalac(repak: 0)
guard 🐖.hanyRepadVanKismalac() == 1 else {
    fatalError("Répa underflow!")
}
