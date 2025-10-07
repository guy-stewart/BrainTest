import SwiftUI

// MARK: - Reaction Time View
struct ReactionTimeView: View {
    @StateObject private var viewModel = ReactionTimeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            // Text("Home")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ReactionGraphView()) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                Text("Speed Test")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !viewModel.gameStarted {
                    VStack(spacing: 30) {
                        Text("Test your speed. Click the circle when it turns red")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                        
                        Button(action: {
                            viewModel.startGame()
                        }) {
                            Text("Start")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 50)
                                .padding(.vertical, 20)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(30)
                        }
                    }
                } else {
                    VStack(spacing: 30) {
                        if viewModel.gameEnded {
                            VStack(spacing: 15) {
                                Text("Game Complete!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                Text("Average Reaction Time")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(String(format: "%.3fs", viewModel.averageTime / 1000))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    viewModel.resetGame()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Play Again")
                                    }
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(25)
                                }
                                .padding(.top, 20)
                            }
                        } else {
                            if viewModel.averageTime > 0 {
                                VStack(spacing: 5) {
                                    Text("Average Time")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(String(format: "%.3fs", viewModel.averageTime / 1000))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: {
                                viewModel.handleClick()
                            }) {
                                Circle()
                                    .fill(viewModel.isRed ? Color.red : Color.gray)
                                    .frame(width: 150, height: 150)
                                    .shadow(color: viewModel.isRed ? .red.opacity(0.5) : .clear, radius: 20)
                            }
                            .disabled(!viewModel.isRed)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Reaction Time View Model
class ReactionTimeViewModel: ObservableObject {
    @Published var gameStarted = false
    @Published var gameEnded = false
    @Published var isRed = false
    @Published var clickCount = 1
    @Published var averageTime: Double = 0
    
    private var reactionTimes: [Double] = []
    private var timer: Timer?
    private var redTime: Date?
    private let maxClicks = 5
    
    func startGame() {
        gameStarted = true
        gameEnded = false
        isRed = false
        clickCount = 1
        averageTime = 0
        reactionTimes = []
        scheduleRedCircle()
    }
    
    func resetGame() {
        timer?.invalidate()
        gameStarted = false
        gameEnded = false
        isRed = false
        clickCount = 1
        averageTime = 0
        reactionTimes = []
        redTime = nil
    }
    
    func handleClick() {
        if isRed {
            if let redTime = redTime {
                let reactionTime = Date().timeIntervalSince(redTime) * 1000
                reactionTimes.append(reactionTime)
                averageTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            }
            
            isRed = false
            clickCount += 1
            
            if clickCount > maxClicks {
                endGame()
            } else {
                scheduleRedCircle()
            }
        }
    }
    
    private func scheduleRedCircle() {
        timer?.invalidate()
        
        let randomDelay = Double.random(in: 1.0...5.0)
        
        timer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRed = true
                self.redTime = Date()
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        gameEnded = true
        saveToCSV()
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(format: "%.3f", averageTime / 1000)
        let csvLine = "\(timestamp),Reaction,,\(score)\n"
        
        do {
            if !fileManager.fileExists(atPath: fileURL.path) {
                // Create file with header if it doesn't exist
                let header = "Timestamp,Test,,Score\n"
                try header.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Append the new score
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                if let data = csvLine.data(using: .utf8) {
                    fileHandle.write(data)
                }
            }
        } catch {
            print("Error writing to CSV: \(error)")
        }
    }
}

// MARK: - Preview
struct ReactionTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionTimeView()
    }
}
