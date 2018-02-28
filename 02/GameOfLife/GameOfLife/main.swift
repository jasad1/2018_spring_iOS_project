import Foundation

// Feladat 20: nagy feladat 3
// Írj egy általános Life-like cellular automaton-t
// A Game of Life általánosítását kell megcsinálni

// Van egy négyzethálós cellákból áló mezőnk ahol minden cella vagy él vagy halott
// Iterációnként értékeljük ki a szabályokat és döntjük el, hogy melyik mező él vagy hal meg
// Minden cellának vannak szomszédai, összesen max 8 szomszédja lehet egy cellának (széleken kérdéses)

// Két féle szabály van:
//      * Survive (S): felsorolás szerűen hány darab élő szomszéd esetén él túl egy cella a következő iterációba
//      * Born (B): felsorolás szerűen hány darab élő szomszéd esetén születik (támad fel) egy cella

// A megejelnítést command lineon csináljátok jó öreg ascii art segítségével
// Ehhez is érdemes egy XCode command line projektet csinálni

// Pl. A jól ismert Game of Life kifejezhető ezekkel a szabályokkal: B3/S23
//          * pontosan 3 szomszéd esetén feltámad egy cella
//          * pontosan 2 vagy 3 szomszéd esetén túlél egy már élő cella a következő iterációba

extension String {
    var lastIndex: String.Index {
        get {
            return self.index(self.endIndex, offsetBy: -1)
        }
    }
}

class GameOfLife {
    private var size: Int!
    private var map: [Bool] = []
    
    private var bornRule: [Int] = []
    private var surviveRule: [Int] = []
    
    init?(size: Int, rule: String) {
        self.size = size
        
        // Randomly initialize map
        for _ in 1...size*size {
            map.append(arc4random_uniform(2) == 1)
        }
        
        // Parse rule
        let lowerRule = rule.lowercased()
        
        if let bIdx = lowerRule.index(of: "b") {
            for i in 1..<lowerRule.count {
                if let numIdx = lowerRule.index(bIdx, offsetBy: i, limitedBy: lowerRule.lastIndex) {
                    if lowerRule[numIdx] == "s" {
                        break
                    }
                    
                    let int = Int(String(lowerRule[numIdx]))
                    if int == nil {
                        print("ERROR: Invalid number in rule!")
                        return nil
                    }
                    bornRule.append(int!)
                } else {
                    break
                }
            }
        } else {
            print("ERROR: Born rule not found!")
            return nil
        }
        
        if let sIdx = lowerRule.index(of: "s") {
            for i in 1..<lowerRule.count {
                if let numIdx = lowerRule.index(sIdx, offsetBy: i, limitedBy: lowerRule.lastIndex) {
                    if lowerRule[numIdx] == "b" {
                        break
                    }
                    
                    let int = Int(String(lowerRule[numIdx]))
                    if int == nil {
                        print("ERROR: Invalid number in rule!")
                        return nil
                    }
                    surviveRule.append(int!)
                } else {
                    break
                }
            }
        } else {
            print("ERROR: Survive rule not found!")
            return nil
        }
    }
    
    private func stringRepr() -> String {
        var result = ""
        for i in 0..<size {
            for j in 0..<size {
                result.append(map[i * size + j] ? "X" : " ")
            }
            result.append("\n")
        }
        return result
        
    }
    
    func run() -> String {
        var newMap: [Bool] = Array(repeating: false, count: size * size)
        
        for i in 0..<size {
            for j in 0..<size {
                // Calculate sum for cell
                var sum = 0
                for x in -1...1 {
                    let ii = i + x
                    if ii < 0 || ii >= size {
                        continue
                    }
                    
                    for y in -1...1 {
                        let jj = j + y
                        if jj < 0 || jj >= size {
                            continue
                        }
                        
                        if map[ii * size + jj] {
                            sum += 1
                        }
                    }
                }
                // Do not include ourself
                if map[i * size + j] {
                    sum -= 1
                }
                
                // Apply rules
                if map[i * size + j] {
                    // If cell lives, only check survive rules
                    for s in surviveRule {
                        if sum == s {
                            newMap[i * size + j] = true
                            break
                        }
                    }
                } else {
                    // If cell was not alive, check born rules
                    for b in bornRule {
                        if sum == b {
                            newMap[i * size + j] = true
                            break
                        }
                    }
                }
            }
        }
        map = newMap
        
        return stringRepr()
    }
}

if CommandLine.arguments.count < 4 {
    print("ERROR: Invalid arguments!")
    print("Usage: <app> size rule numOfIterations")
    exit(1)
}

let size = Int(CommandLine.arguments[1])
if size == nil {
    print("ERROR: Invalid size!")
    exit(1)
}

let rule = CommandLine.arguments[2]

let numOfIterations = Int(CommandLine.arguments[3])
if numOfIterations == nil {
    print("ERROR: Invalid numOfIterations!")
    exit(1)
}

let gol = GameOfLife(size: size!, rule: rule)
if gol == nil {
    print("ERROR: Failed to initialize game of life!")
    exit(1)
}

for _ in 1...numOfIterations! {
    let str = gol!.run()
    print("\u{001B}[2J")
    print(str)
    usleep(250000)
}
