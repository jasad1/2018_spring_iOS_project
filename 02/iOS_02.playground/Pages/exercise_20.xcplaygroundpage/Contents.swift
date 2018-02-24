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


