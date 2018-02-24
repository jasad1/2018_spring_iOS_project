import Foundation

// Feladat 13: Érjük el, hogy a dobókock mindig 6-ot dobjon

struct Dice {
    
    var generator: () -> Int
    
    func rollDice() -> Int {
        return generator()
    }
}

var 🎲 = Dice(generator: {
    return Int(arc4random()) % 6 + 1
})

🎲.rollDice()
🎲.rollDice()
🎲.rollDice()

// Ide írj
🎲.generator = { return 6 }
// Idáig

guard 🎲.rollDice() == 6 && 🎲.rollDice() == 6 && 🎲.rollDice() == 6 else {
    fatalError()
}
