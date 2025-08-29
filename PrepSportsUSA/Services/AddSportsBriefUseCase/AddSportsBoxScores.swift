

// MARK: - Golf Boxscore
struct GolfBoxscore: Codable {
    let homeTeam: GolfTeamScores
    let awayTeam: GolfTeamScores
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
}

struct GolfTeamScores: Codable {
    let one: Int
    let two: Int
    let three: Int
    let four: Int
    let five: Int
    let six: Int
    let seven: Int
    let eight: Int
    let nine: Int
    let ten: Int
    let eleven: Int
    let twelve: Int
    let thirteen: Int
    let fourteen: Int
    let fifteen: Int
    let sixteen: Int
    let seventeen: Int
    let eighteen: Int
    let out: Int
    let `in`: Int
    let tot: Int
    
    enum CodingKeys: String, CodingKey {
        case one, two, three, four, five, six, seven, eight, nine, ten
        case eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen
        case out = "OUT"
        case `in` = "IN"
        case tot = "TOT"
    }
    
    init(scores: [Int]) {
        // Ensure we have exactly 18 scores
        let paddedScores = scores + Array(repeating: 0, count: max(0, 18 - scores.count))
        
        self.one = paddedScores[0]
        self.two = paddedScores[1]
        self.three = paddedScores[2]
        self.four = paddedScores[3]
        self.five = paddedScores[4]
        self.six = paddedScores[5]
        self.seven = paddedScores[6]
        self.eight = paddedScores[7]
        self.nine = paddedScores[8]
        self.ten = paddedScores[9]
        self.eleven = paddedScores[10]
        self.twelve = paddedScores[11]
        self.thirteen = paddedScores[12]
        self.fourteen = paddedScores[13]
        self.fifteen = paddedScores[14]
        self.sixteen = paddedScores[15]
        self.seventeen = paddedScores[16]
        self.eighteen = paddedScores[17]
        
        // Calculate OUT (holes 1-9)
        self.out = Array(paddedScores[0..<9]).reduce(0, +)
        
        // Calculate IN (holes 10-18)
        self.in = Array(paddedScores[9..<18]).reduce(0, +)
        
        // Calculate TOTAL
        self.tot = paddedScores.reduce(0, +)
    }
}

// MARK: - Set-Based Boxscore (Tennis & Volleyball)
struct SetBasedBoxscore: Codable {
    let homeTeam: SetBasedTeamScores
    let awayTeam: SetBasedTeamScores
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
}

struct SetBasedTeamScores: Codable {
    let firstSet: Int
    let secondSet: Int
    let thirdSet: Int
    let fourthSet: Int
    let fifthSet: Int
    let finalScore: Int
    
    enum CodingKeys: String, CodingKey {
        case firstSet = "first_set"
        case secondSet = "second_set"
        case thirdSet = "third_set"
        case fourthSet = "fourth_set"
        case fifthSet = "fifth_set"
        case finalScore = "final_score"
    }
    
    init(scores: [Int]) {
        // Ensure we have exactly 5 scores
        let paddedScores = scores + Array(repeating: 0, count: max(0, 5 - scores.count))
        
        self.firstSet = paddedScores[0]
        self.secondSet = paddedScores[1]
        self.thirdSet = paddedScores[2]
        self.fourthSet = paddedScores[3]
        self.fifthSet = paddedScores[4]
        
        // Calculate final score (sum of all sets)
        self.finalScore = paddedScores.reduce(0, +)
    }
}

// MARK: - Type Aliases for Backward Compatibility
typealias TennisBoxscore = SetBasedBoxscore
typealias TennisTeamScores = SetBasedTeamScores
typealias VolleyballBoxscore = SetBasedBoxscore
typealias VolleyballTeamScores = SetBasedTeamScores
