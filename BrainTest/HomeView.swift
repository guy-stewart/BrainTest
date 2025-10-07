import SwiftUI
import Speech
import AVFoundation

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
                            Text("Home")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                    }
                    Spacer()
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
                            Text("Home")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                    }
                    Spacer()
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
                                Text("Home")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(15)
                        }
                        Spacer()
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

// MARK: - Speech Recognizer
class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }
    
    func start() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                self.stop()
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        transcript = ""
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
