import Foundation

// Feladat 19: nagy feladat 2
// Írj egy OneTimePad nevű osztályt ami a one-time-pad titkosítást valósítja meg
// A OneTimePad komformáljon az Encryption protocolhoz
// A one-time pad titkosítás feltörhetetlen (tényleg)
// A one-time pad titkosítás lényegében annyi, hogy egy szövegnek a karaktereit eltolja egy másik "kulcs" karaktersorozat értékeivel
// Ehhez is érdemes egy XCode command line projektet csinálni

// Pl "abc" eltolva a "afd" kulcsal: "bhg"
// (mert a: 1, b: 2, c: 3    a: 1, f: 6, d: 4  a+a = 1+1 = 2 = b, b+f = 2+6 = 8 = h, c+d = 3+4 = 7 = g -> "bhg")

protocol Encryption {
    func encrypt(plaintext: String) -> String?
    func decrypt(cyphertext: String) -> String?
}
