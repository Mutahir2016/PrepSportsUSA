import SwiftUI

struct GolfBoxScoreView: View {
    @Binding var homeScores: [Int]
    @Binding var awayScores: [Int]
    
    // Local state that will trigger view updates
    @State private var localHomeScores: [Int] = Array(repeating: 0, count: 18)
    @State private var localAwayScores: [Int] = Array(repeating: 0, count: 18)

    let homeTeamName: String
    let awayTeamName: String
    let homeTeamImageURL: String?
    let awayTeamImageURL: String?
    
    // Computed properties for final scores that will update automatically
    private var homeOutScore: Int {
        localHomeScores[0..<9].reduce(0, +)
    }
    
    private var awayOutScore: Int {
        localAwayScores[0..<9].reduce(0, +)
    }
    
    private var homeInScore: Int {
        localHomeScores[9..<18].reduce(0, +)
    }
    
    private var awayInScore: Int {
        localAwayScores[9..<18].reduce(0, +)
    }
    
    private var homeTotalScore: Int {
        localHomeScores.reduce(0, +)
    }
    
    private var awayTotalScore: Int {
        localAwayScores.reduce(0, +)
    }

    // MARK: - Boxscore Creation
    func createGolfBoxscore() -> GolfBoxscore {
        return GolfBoxscore(
            homeTeam: GolfTeamScores(scores: homeScores),
            awayTeam: GolfTeamScores(scores: awayScores)
        )
    }

    // MARK: - Score Validation
    private func scoreBinding(for team: TeamType, at index: Int) -> Binding<String> {
        Binding(
            get: {
                let value = team == .home ? localHomeScores[index] : localAwayScores[index]
                return value == 0 ? "" : String(value)
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
                // Golf Box Score title
                Text("Golf Box Score")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                // Team names with images
                teamNamesAndImagesSection

                // First 9 holes (OUT)
                VStack(spacing: 15) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("Team")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)

                        ForEach(1...9, id: \.self) { hole in
                            Text("\(hole)")
                                .font(.caption)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                        }

                        Text("OUT")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }

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

                        ForEach(0..<9, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .away, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }

                        Text("\(awayOutScore)")
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

                        ForEach(0..<9, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .home, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }

                        Text("\(homeOutScore)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                }

                // Second 9 holes (IN)
                VStack(spacing: 15) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("Team")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)

                        ForEach(10...18, id: \.self) { hole in
                            Text("\(hole)")
                                .font(.caption)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                        }

                        Text("IN")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }

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

                        ForEach(9..<18, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .away, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }

                        Text("\(awayInScore)")
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

                        ForEach(9..<18, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: .home, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }

                        Text("\(homeInScore)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                }

                // Total section
                HStack {
                    Text("TOTAL")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Spacer()

                    HStack(spacing: 20) {
                        Text("\(awayTotalScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("\(homeTotalScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
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
struct UnderlinedTextFieldStyle: TextFieldStyle {
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
