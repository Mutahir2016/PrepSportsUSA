import SwiftUI

struct GolfBoxScoreView: View {
    @State private var homeScores: [Int] = Array(repeating: 0, count: 18)
    @State private var awayScores: [Int] = Array(repeating: 0, count: 18)
    
    let homeTeamName: String
    let awayTeamName: String
    let homeTeamImageURL: String?
    let awayTeamImageURL: String?
    
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
                        Text("Away")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(0..<9, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: $awayScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(awayScores[0..<9].reduce(0, +))")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                    
                    // Home row (bottom)
                    HStack(spacing: 0) {
                        Text("Home")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(0..<9, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: $homeScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(homeScores[0..<9].reduce(0, +))")
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
                        Text("Away")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(9..<18, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: $awayScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(awayScores[9..<18].reduce(0, +))")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .trailing)
                    }
                    
                    // Home row (bottom)
                    HStack(spacing: 0) {
                        Text("Home")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(9..<18, id: \.self) { index in
                            TextField("0", text: scoreBinding(for: $homeScores, at: index))
                                .textFieldStyle(UnderlinedTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 4)
                        }
                        
                        Text("\(homeScores[9..<18].reduce(0, +))")
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
                        Text("\(awayScores.reduce(0, +))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("\(homeScores.reduce(0, +))")
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

#Preview {
    GolfBoxScoreView(
        homeTeamName: "Florida Gulf Coast Eagles",
        awayTeamName: "AAMU Bulldogs",
        homeTeamImageURL: nil,
        awayTeamImageURL: nil
    )
    .background(Color.gray.opacity(0.1))
}
