import SwiftUI

// MARK: - Tap Test View
struct TapTestView: View {
    @State private var tapCount = 0
    @State private var timeRemaining = 10.0
    @State private var isTimerRunning = false
    @State private var isButtonDisabled = false
    @State private var buttonLabel = "Tap Me"
    @Environment(\.dismiss) private var dismiss
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
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
                
                NavigationLink(destination: TapGraphView()) {
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
            
            Text("Tap Test Challenge")
                .font(.title)
                .foregroundColor(.white)
            
            Text("Tap as many times as you can in 10 seconds")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Time: \(String(format: "%.1f", max(timeRemaining, 0.0))) seconds")
                .font(.title2)
                .padding()
            
            Text("Taps: \(tapCount)")
                .font(.title2)
                .padding()
            
            Spacer()
            
            Button(action: {
                handleTap()
            }) {
                Text(buttonLabel)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isButtonDisabled)
            .padding(.horizontal)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 0.1
                if timeRemaining <= 0 {
                    endGame()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func handleTap() {
        if buttonLabel == "Play Again" {
            resetGame()
        } else if !isButtonDisabled {
            tapCount += 1
            if !isTimerRunning {
                isTimerRunning = true
            }
        }
    }
    
    private func endGame() {
        isTimerRunning = false
        isButtonDisabled = true
        buttonLabel = "Play Again"
        saveToCSV()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isButtonDisabled = false
        }
    }
    
    private func resetGame() {
        tapCount = 0
        timeRemaining = 10.0
        isTimerRunning = false
        buttonLabel = "Tap Me"
        isButtonDisabled = false
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(tapCount)
        let csvLine = "\(timestamp),Tap,,\(score)\n"
        
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
struct TapTestView_Previews: PreviewProvider {
    static var previews: some View {
        TapTestView()
    }
}
