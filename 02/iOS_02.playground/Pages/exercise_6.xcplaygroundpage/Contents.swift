import Foundation

// Feladat 6: Írj egy fv-t ami egyszerre visszaadja a max és min értéket egy tömbben
// a feladat akkor sikeres ha a végén sikerül kiíratni ezt: 🐽

// pro tip: valahol itt kezdj el írni egy 'minAndMax' nevű fv-t ami egy Int tömböt ('[INT]') vár bemenetnek

func minAndMax(_ arr: [Int]) -> (min: Int, max: Int) {
    guard !arr.isEmpty else {
        return (0, 0)
    }
    
    var min = arr[0]
    var max = arr[0]
    
    arr.forEach {
        if $0 < min {
            min = $0
        } else if $0 > max {
            max = $0
        }
    }
    
    return (min, max)
}

// ✋🏽 Ehhez ne nyúlj! 🛑
let arr = [2, 3, 5, 7, 11, 13, 17, 19]

let minMax = minAndMax(arr)

if minMax.min == 2 && minMax.max == 19 {
    print("🐽")
}
