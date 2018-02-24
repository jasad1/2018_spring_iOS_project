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

extension String {
    var lastIndex: String.Index {
        get {
            return self.index(self.endIndex, offsetBy: -1)
        }
    }
}

extension Character {
    // NOTE: This is really inefficient.
    var isLowercase: Bool {
        get {
            let str = String(self)
            return str.lowercased() == str
        }
    }
}

class CaesarsCypher: Encryption {
    private static let CHARACTERS_L = "abcdefghijklmnopqrstuvxyz"
    private static let CHARACTERS_U = "ABCDEFGHIJKLMNOPQRSTUVXYZ"
    
    private var shift: Int!
    
    init(shift: Int) {
        self.shift = shift
    }
    
    func encrypt(plaintext: String) -> String? {
        var ret = ""
        
        for char in plaintext.characters {
            let chars = char.isLowercase ? CaesarsCypher.CHARACTERS_L : CaesarsCypher.CHARACTERS_U
            
            let idx = chars.characters.index(of: char)
            if idx == nil {
                print("ERROR: Character not supported!")
                return nil
            }
            
            if let newIdx = chars.index(idx!, offsetBy: shift, limitedBy: chars.lastIndex) {
                ret.append(chars[newIdx])
            } else {
                if let newIdxWrap = chars.index(idx!, offsetBy: shift - chars.characters.count, limitedBy: chars.startIndex) {
                    ret.append(chars[newIdxWrap])
                } else {
                    print("ERROR: Should not happen!")
                    return nil
                }
            }
        }
        return ret
    }
    
    func decrypt(cyphertext: String) -> String? {
        var ret = ""
        
        for char in cyphertext.characters {
            let chars = char.isLowercase ? CaesarsCypher.CHARACTERS_L : CaesarsCypher.CHARACTERS_U
            
            let idx = chars.characters.index(of: char)
            if idx == nil {
                print("ERROR: Character not supported!")
                return nil
            }
            
            if let newIdx = chars.index(idx!, offsetBy: -shift, limitedBy: chars.startIndex) {
                ret.append(chars[newIdx])
            } else {
                if let newIdxWrap = chars.index(idx!, offsetBy: -shift + chars.characters.count, limitedBy: chars.lastIndex) {
                    ret.append(chars[newIdxWrap])
                } else {
                    print("ERROR: Should not happen!")
                    return nil
                }
            }
        }
        return ret
    }
}

if CommandLine.arguments.count < 4 {
    print("ERROR: Invalid arguments!")
    print("Usage: <app> encrypt|decrypt shift text")
    exit(1)
}

let shift = Int(CommandLine.arguments[2])
if shift == nil {
    print("ERROR: Invalid shift amount!")
    exit(1)
}
let text = CommandLine.arguments[3]

let cypher = CaesarsCypher(shift: shift!)

switch CommandLine.arguments[1] {
case "encrypt":
    print(cypher.encrypt(plaintext: text) ?? "ERROR: Could not encrypt text!")
    
case "decrypt":
    print(cypher.decrypt(cyphertext: text) ?? "ERROR: Could not decrypt text!")
    
default:
    print("ERROR: Unknown command! It should be 'encrypt' or 'decrypt'.")
}
