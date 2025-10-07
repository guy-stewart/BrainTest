import SwiftUI

// MARK: - Moving Dot View
struct MovingDotView: View {
    @StateObject private var viewModel = MovingDotViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
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
                        
                        NavigationLink(destination: MovingDotGraphView()) {
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
                    
                    if !viewModel.gameStarted {
                        Spacer()
                        
                        VStack(spacing: 30) {
                            Text("Click on the moving dot as quickly as you can.")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                viewModel.startGame(screenSize: geometry.size)
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
                        
                        Spacer()
                    } else if viewModel.gameEnded {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Time")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(String(format: "%.3fs", viewModel.finalTime))
                                .font(.system(size: 56, weight: .bold))
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
                        
                        Spacer()
                    } else {
                        Text(String(format: "%.3f", viewModel.elapsedTime))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 50)
                        
                        Spacer()
                    }
                }
                
                if viewModel.gameStarted && !viewModel.gameEnded {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 10, height: 10)
                        .position(viewModel.dotPosition)
                        .onTapGesture {
                            viewModel.dotTapped()
                        }
                }
            }
            .onAppear {
                viewModel.screenSize = geometry.size
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Moving Dot View Model
class MovingDotViewModel: ObservableObject {
    @Published var gameStarted = false
    @Published var gameEnded = false
    @Published var dotPosition = CGPoint.zero
    @Published var elapsedTime: Double = 0
    @Published var finalTime: Double = 0
    
    var screenSize = CGSize.zero
    private var dotVelocity = CGPoint.zero
    private var gameTimer: Timer?
    private var animationTimer: Timer?
    private var startTime: Date?
    private let gameDuration: Double = 60.0
    private let initialSpeed: Double = 400.0
    
    func startGame(screenSize: CGSize) {
        self.screenSize = screenSize
        gameStarted = true
        gameEnded = false
        elapsedTime = 0
        finalTime = 0
        
        dotPosition = CGPoint(
            x: CGFloat.random(in: 50...(screenSize.width - 50)),
            y: CGFloat.random(in: 100...(screenSize.height - 100))
        )
        
        let angle = CGFloat.random(in: 0...(2 * .pi))
        dotVelocity = CGPoint(
            x: _math.cos(angle) * initialSpeed,
            y: _math.sin(angle) * initialSpeed
        )
        
        startTime = Date()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            DispatchQueue.main.async {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updateDotPosition()
        }
    }
    
    func resetGame() {
        gameTimer?.invalidate()
        animationTimer?.invalidate()
        gameStarted = false
        gameEnded = false
        elapsedTime = 0
        finalTime = 0
        dotPosition = .zero
        dotVelocity = .zero
        startTime = nil
    }
    
    func dotTapped() {
        gameTimer?.invalidate()
        animationTimer?.invalidate()
        finalTime = elapsedTime
        gameEnded = true
        saveToCSV()
    }
    
    private func updateDotPosition() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let speedMultiplier = max(0, 1.0 - (elapsed / gameDuration))
        
        let deltaTime = 1.0 / 60.0
        var newX = dotPosition.x + (dotVelocity.x * speedMultiplier * deltaTime)
        var newY = dotPosition.y + (dotVelocity.y * speedMultiplier * deltaTime)
        
        let dotRadius: CGFloat = 5
        
        if newX <= dotRadius {
            newX = dotRadius
            dotVelocity.x = abs(dotVelocity.x)
        } else if newX >= screenSize.width - dotRadius {
            newX = screenSize.width - dotRadius
            dotVelocity.x = -abs(dotVelocity.x)
        }
        
        if newY <= dotRadius {
            newY = dotRadius
            dotVelocity.y = abs(dotVelocity.y)
        } else if newY >= screenSize.height - dotRadius {
            newY = screenSize.height - dotRadius
            dotVelocity.y = -abs(dotVelocity.y)
        }
        
        DispatchQueue.main.async {
            self.dotPosition = CGPoint(x: newX, y: newY)
        }
        
        if elapsed >= gameDuration {
            dotTapped()
        }
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(format: "%.3f", finalTime)
        let csvLine = "\(timestamp),Dot,,\(score)\n"
        
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
struct MovingDotView_Previews: PreviewProvider {
    static var previews: some View {
        MovingDotView()
    }
}
