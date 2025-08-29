import SwiftUI

struct TennisBoxScoreView: View {
    @Binding var homeScores: [Int]
    @Binding var awayScores: [Int]
    
    // Local state that will trigger view updates
    @State private var localHomeScores: [Int] = Array(repeating: 0, count: 5)
    @State private var localAwayScores: [Int] = Array(repeating: 0, count: 5)

    let homeTeamName: String
    let awayTeamName: String
    let homeTeamImageURL: String?
    let awayTeamImageURL: String?
    let isTennisScore: Bool
    
    // Computed properties for final scores that will update automatically
    private var homeFinalScore: Int {
        isTennisScore ? localHomeScores.reduce(0, +) : calculateSetsWon(localHomeScores, localAwayScores)
    }
    
    private var awayFinalScore: Int {
        isTennisScore ? localAwayScores.reduce(0, +) : calculateSetsWon(localAwayScores, localHomeScores)
    }

    // Calculate sets won for volleyball scoring
    private func calculateSetsWon(_ teamScores: [Int], _ opponentScores: [Int]) -> Int {
        var setsWon = 0
        for i in 0..<teamScores.count {
            if teamScores[i] > 0 || opponentScores[i] > 0 {
                if teamScores[i] > opponentScores[i] {
                    setsWon += 1
                }
            }
        }
        return setsWon
    }

    // Custom binding for score validation
    private func scoreBinding(for team: TeamType, at index: Int) -> Binding<String> {
        Binding(
            get: {
                let value = team == .home ? localHomeScores[index] : localAwayScores[index]
                return String(value)
            },
            set: { newValue in
                // Remove spaces
                let noSpaces = newValue.replacingOccurrences(of: " ", with: "")

                // Remove non-numeric characters
                let numericOnly = noSpaces.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

                // Limit to 2 characters
                let limitedValue = String(numericOnly.prefix(2))

                // Convert to Int, default to 0 if invalid
                let intValue = Int(limitedValue) ?? 0
                
                // Update both local state (for UI reactivity) and binding (for parent)
                if team == .home {
                    localHomeScores[index] = intValue
                    homeScores[index] = intValue
                } else {
                    localAwayScores[index] = intValue
                    awayScores[index] = intValue
                }
            }
        )
    }
    
    private enum TeamType {
        case home, away
    }

    // MARK: - Team Display Methods

    @ViewBuilder
    private var teamNamesAndImagesSection: some View {
        HStack {
            // Away team on the left
            teamInfoView(
                teamName: awayTeamName,
                imageURL: awayTeamImageURL,
                isHomeTeam: false
            )

            Spacer()

            // Home team on the right
            teamInfoView(
                teamName: homeTeamName,
                imageURL: homeTeamImageURL,
                isHomeTeam: true
            )
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func teamInfoView(teamName: String, imageURL: String?, isHomeTeam: Bool) -> some View {
        VStack(spacing: 8) {
            // Team image
            AsyncImage(url: URL(string: imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)

            Text(teamName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main card
            VStack(spacing: 20) {
                // Tennis Box Score title
                Text(isTennisScore ? "Tennis Box Score" : "Volleyball Box Score")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                // Team names with images
                teamNamesAndImagesSection

                // Score table section
                VStack(spacing: 15) {
                    // Header row with light gray background
                    HStack(spacing: 0) {
                        Text("Team")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)

                        ForEach(1...5, id: \.self) { set in
                            Text("Set \(set)")
                                .font(.caption)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                        }

                        Text("Final")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)

                    // Away row (top)
                    HStack(spacing: 0) {
                        AsyncImage(url: URL(string: awayTeamImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 35, height: 35)
                        .padding(.trailing, 10)

                        ForEach(0..<5, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .away, at: index))
                                .textFieldStyle(TennisUnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                                .keyboardType(.numberPad)
                        }

                        Text("\(awayFinalScore)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }

                    // Home row (bottom)
                    HStack(spacing: 0) {
                        AsyncImage(url: URL(string: homeTeamImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 35, height: 35)
                        .padding(.trailing, 10)

                        ForEach(0..<5, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .home, at: index))
                                .textFieldStyle(TennisUnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                                .keyboardType(.numberPad)
                        }

                        Text("\(homeFinalScore)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(20)
            .background(Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .background(Color.clear)
        .onAppear {
            // Sync local state with bindings on appear
            localHomeScores = homeScores
            localAwayScores = awayScores
        }
    }
}

// Custom text field style with underline
struct TennisUnderlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(spacing: 2) {
            configuration
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.center)
                .foregroundColor(.primary) // Use system text color

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
        }
    }
}
