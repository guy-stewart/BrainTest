import SwiftUI
import Speech
import AVFoundation
import Combine

// MARK: - Countdown View
struct CountdownView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                
                NavigationLink(destination: CountdownGraphView()) {
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
            
            Text("Countdown Challenge")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text(viewModel.message)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("Current Number: \(viewModel.currentNumber)")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
            Text("Time: \(String(format: "%.1f", viewModel.elapsedTime)) seconds")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
            Spacer()
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
        .onAppear {
            viewModel.startChallenge()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Countdown View Model
class CountdownViewModel: ObservableObject {
    @Published var currentNumber = 0
    @Published var message = "Please count down by 7"
    @Published var elapsedTime = 0.0
    @Published var isChallengeComplete = false
    
    private var expectedNumbers: [Int] = []
    private var correctCount = 0
    private var speechRecognizer = SpeechRecognizer()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    func startChallenge() {
        // Generate random starting number between 60 and 90
        currentNumber = Int.random(in: 60...90)
        expectedNumbers = []
        correctCount = 0
        message = "Please count down by 7"
        elapsedTime = 0.0
        isChallengeComplete = false
        
        // Generate the sequence of 5 expected numbers (starting from the next number)
        for i in 1...5 {
            expectedNumbers.append(currentNumber - (i * 7))
        }
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !self.isChallengeComplete {
                    self.elapsedTime += 0.1
                }
            }
        }
        
        // Start speech recognition with a slight delay to avoid capturing initial display
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.speechRecognizer.stop()
            self.speechRecognizer.transcript = ""
            self.speechRecognizer.start()
            
            // Observe transcript changes
            self.speechRecognizer.$transcript
                .sink { [weak self] transcript in
                    self?.processTranscript(transcript)
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func processTranscript(_ transcript: String) {
        guard !isChallengeComplete else { return }
        
        // Process only non-empty transcripts
        guard !transcript.isEmpty else { return }
        
        // Extract the last two characters of the transcript
        let lastTwoChars = String(transcript.suffix(2))
        
        // Check if the last two characters form a valid number matching the expected number
        if let spokenNumber = Int(lastTwoChars), spokenNumber == expectedNumbers[correctCount] {
            correctCount += 1
            DispatchQueue.main.async {
                self.currentNumber = spokenNumber
                if self.correctCount >= 5 {
                    self.message = "Congratulations!"
                    self.isChallengeComplete = true
                    self.timer?.invalidate()
                    self.speechRecognizer.stop()
                    self.saveToCSV()
                }
            }
        }
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(format: "%.1f", elapsedTime)
        let csvLine = "\(timestamp),Countdown,,\(score)\n"
        
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

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView()
    }
}
