import SwiftUI

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Brain Test")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            NavigationLink(destination: WordChallengeView()) {
                                ChallengeButtonView(title: "Letter Challenge", icon: "text.bubble.fill")
                            }
                            
                            NavigationLink(destination: ReactionTimeView()) {
                                ChallengeButtonView(title: "Speed Test", icon: "stopwatch.fill")
                            }
                            
                            NavigationLink(destination: MovingDotView()) {
                                ChallengeButtonView(title: "Dot Challenge", icon: "circle.fill")
                            }
                            
                            NavigationLink(destination: ShortTermMemoryView()) {
                                ChallengeButtonView(title: "Memory Challenge", icon: "brain")
                            }
                            
                            NavigationLink(destination: TapTestView()) {
                                ChallengeButtonView(title: "Tap Test", icon: "hand.tap")
                            }
                            
                            NavigationLink(destination: CountdownView()) {
                                ChallengeButtonView(title: "Countdown Challenge", icon: "number.circle.fill")
                            }
                            
                            NavigationLink(destination: TriviaView()) {
                                ChallengeButtonView(title: "Trivia Challenge", icon: "questionmark.circle.fill")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Challenge Button View
struct ChallengeButtonView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.3))
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

// MARK: - Main App
struct LetterChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
