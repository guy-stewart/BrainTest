import SwiftUI
import Speech
import AVFoundation

// MARK: - Word Challenge View
struct WordChallengeView: View {
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple, Color.pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                    
                    NavigationLink(destination: WordChallengeGraphView()) {
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
                
                Text("Letter Challenge")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !viewModel.gameStarted {
                    StartGameView(viewModel: viewModel)
                } else {
                    GamePlayView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.requestPermissions()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Start Game View
struct StartGameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Say as many words as you can that start with a random letter in 30 seconds!")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(30)
            }
        }
    }
}

// MARK: - Game Play View
struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                VStack(spacing: 8) {
                    Text("Say words starting with:")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(viewModel.targetLetter)
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                }
                
                HStack(spacing: 20) {
                    Text("\(viewModel.timeLeft)s")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: viewModel.isListening ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 28))
                        .foregroundColor(viewModel.isListening ? .red : .white.opacity(0.5))
                        .opacity(viewModel.isListening ? (viewModel.timeLeft % 2 == 0 ? 1.0 : 0.5) : 1.0)
                }
                .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Words Starting with \(viewModel.targetLetter): \(viewModel.matchingWords.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if viewModel.matchingWords.isEmpty {
                        Text("Start speaking words that begin with \"\(viewModel.targetLetter)\"")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                    } else {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.matchingWords, id: \.self) { word in
                                Text(word)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.green)
                                    .cornerRadius(18)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .frame(minHeight: 150)
                
                if viewModel.gameEnded {
                    VStack(spacing: 8) {
                        Text("Game Over!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text("You found \(viewModel.matchingWords.count) word\(viewModel.matchingWords.count != 1 ? "s" : "")!")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)
                }
                
                Button(action: {
                    viewModel.resetGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("New Game")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(25)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Flow Layout for Word Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Game View Model
class GameViewModel: NSObject, ObservableObject {
    @Published var targetLetter = ""
    @Published var isListening = false
    @Published var timeLeft = 30
    @Published var matchingWords: [String] = []
    @Published var gameStarted = false
    @Published var gameEnded = false
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var timer: Timer?
    private var seenWords = Set<String>()
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }
    
    func startGame() {
        targetLetter = getRandomLetter()
        gameStarted = true
        gameEnded = false
        timeLeft = 30
        matchingWords = []
        seenWords = []
        isListening = true
        
        startListening()
        startTimer()
    }
    
    func resetGame() {
        stopListening()
        timer?.invalidate()
        gameStarted = false
        gameEnded = false
        isListening = false
        timeLeft = 30
        matchingWords = []
        seenWords = []
        targetLetter = ""
    }
    
    private func getRandomLetter() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String(letters.randomElement()!)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.timeLeft -= 1
                
                if self.timeLeft <= 0 {
                    self.endGame()
                }
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        stopListening()
        isListening = false
        gameEnded = true
        saveToCSV()
    }
    
    private func startListening() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let transcript = result.bestTranscription.formattedString.lowercased()
                    let words = transcript.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                    
                    DispatchQueue.main.async {
                        for word in words {
                            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
                            if cleanWord.hasPrefix(self.targetLetter.lowercased()) && !self.seenWords.contains(cleanWord) {
                                self.seenWords.insert(cleanWord)
                                self.matchingWords.append(cleanWord)
                            }
                        }
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopListening()
                }
            }
            
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    private func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(matchingWords.count)
        let csvLine = "\(timestamp),Letter,,\(score)\n"
        
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
