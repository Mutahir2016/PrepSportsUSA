import SwiftUI

struct TennisBoxScoreView: View {
    @State private var homeScores: [Int] = Array(repeating: 0, count: 5)
    @State private var awayScores: [Int] = Array(repeating: 0, count: 5)
    
    let homeTeamName: String
    let awayTeamName: String
    let homeTeamImageURL: String?
    let awayTeamImageURL: String?
    let isTennisScore: Bool

    // Custom binding for score validation
    private func scoreBinding(for scores: Binding<[Int]>, at index: Int) -> Binding<String> {
        Binding(
            get: { 
                String(scores.wrappedValue[index]) 
            },
            set: { newValue in
                // Remove spaces
                let noSpaces = newValue.replacingOccurrences(of: " ", with: "")
                
                // Remove non-numeric characters
                let numericOnly = noSpaces.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                
                // Limit to 2 characters
                let limitedValue = String(numericOnly.prefix(2))
                
                // Convert to Int, default to 0 if invalid
                if let intValue = Int(limitedValue) {
                    scores.wrappedValue[index] = intValue
                } else {
                    scores.wrappedValue[index] = 0
                }
            }
        )
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
                            TextField("0", text: scoreBinding(for: $awayScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(awayScores.reduce(0, +))")
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
                            TextField("0", text: scoreBinding(for: $homeScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(homeScores.reduce(0, +))")
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

#Preview {
    TennisBoxScoreView(
        homeTeamName: "Reavis Rams",
        awayTeamName: "Lincoln-Way West Warriors",
        homeTeamImageURL: nil,
        awayTeamImageURL: nil,
        isTennisScore: false
    )
    .background(Color.gray.opacity(0.1))
}
