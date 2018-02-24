import Foundation

// Feladat 12: Írj egy fvt a Compass osztálynak ami elfordítja jobbra a várt módon
enum Compass {
    case north
    case east
    case west
    case south
    
    mutating func turnRight() {
        switch self {
        case .north:
            self = .east
        case .east:
            self = .south
        case .south:
            self = .west
        case .west:
            self = .north
        }
    }
}

// ✋🏽 Ehhez ne nyúlj! 🛑
var comp: Compass = .north

comp.turnRight()
guard comp == .east else {
    fatalError()
}

comp.turnRight()
guard comp == .south else {
    fatalError()
}

comp.turnRight()
guard comp == .west else {
    fatalError()
}

comp.turnRight()
guard comp == .north else {
    fatalError()
}
