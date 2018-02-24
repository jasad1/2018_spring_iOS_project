import Foundation

// Feladat 18: nagy feladat 1
// Írj egy CaesarsCypher nevű osztályt ami komformál az Encryption protocolhoz
// A CaesarsCypher a jó öreg cézár titkosítást valósítsa meg
// A cézár titkosítás lényegében annyi, hogy a bemeneti karaktersort eltolja egy konstans értékkel
// Pl az "abc" eltolva 1 értékkel "bcd" 2 értékkel eltolva: "cde"
// Pl "Kismalac" eltolva 1 értékkel "Ljtnbmbd"

// Érdemes a feladathoz létrehozni egy XCode command line projektet. XCode > New Project > macOS > Command Line Tool

protocol Encryption {
    func encrypt(plaintext: String) -> String?
    func decrypt(cyphertext: String) -> String?
}

