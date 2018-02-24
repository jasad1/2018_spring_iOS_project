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

class OneTimePad: Encryption {
    private static let CHARACTERS_L = "abcdefghijklmnopqrstuvxyz"
    private static let CHARACTERS_U = "ABCDEFGHIJKLMNOPQRSTUVXYZ"
    
    private var shiftText: String!
    
    private var shiftArray: [Int] = []
    
    init?(shiftText: String) {
        self.shiftText = shiftText
        
        for char in shiftText.lowercased().characters {
            let chars = OneTimePad.CHARACTERS_L
            
            let idx = chars.characters.index(of: char)
            if idx == nil {
                print("ERROR: Character not supported in shiftText!")
                return nil
            }
            // '+ 1', because indexing starts from zero
            shiftArray.append(chars.distance(from: chars.startIndex, to: idx!) + 1)
        }
    }
    
    func encrypt(plaintext: String) -> String? {
        var ret = ""
        
        for (index, char) in plaintext.characters.enumerated() {
            let chars = char.isLowercase ? OneTimePad.CHARACTERS_L : OneTimePad.CHARACTERS_U
            
            let idx = chars.characters.index(of: char)
            if idx == nil {
                print("ERROR: Character not supported!")
                return nil
            }
            
            let shift = shiftArray[index % shiftText.characters.count]
            
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
        
        for (index, char) in cyphertext.characters.enumerated() {
            let chars = char.isLowercase ? OneTimePad.CHARACTERS_L : OneTimePad.CHARACTERS_U
            
            let idx = chars.characters.index(of: char)
            if idx == nil {
                print("ERROR: Character not supported!")
                return nil
            }
            
            let shift = shiftArray[index % shiftText.characters.count]
            
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
    print("Usage: <app> encrypt|decrypt shiftText text")
    exit(1)
}

let shiftText = CommandLine.arguments[2]
let text = CommandLine.arguments[3]

let cypher = OneTimePad(shiftText: shiftText)
if cypher == nil {
    print("ERROR: Could not initiate cypher!")
    exit(1)
}

switch CommandLine.arguments[1] {
case "encrypt":
    print(cypher!.encrypt(plaintext: text) ?? "ERROR: Could not encrypt text!")
    
case "decrypt":
    print(cypher!.decrypt(cyphertext: text) ?? "ERROR: Could not decrypt text!")
    
default:
    print("ERROR: Unknown command! It should be 'encrypt' or 'decrypt'.")
}
