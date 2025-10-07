import SwiftUI
import Charts

// MARK: - Reaction Graph View
struct ReactionGraphView: View {
    @State private var data: [(date: Date, score: Double)] = []
    @Environment(\.dismiss) private var dismiss
    
    var minScore: Double {
        data.map { $0.score }.min() ?? 0
    }
    
    var maxScore: Double {
        data.map { $0.score }.max() ?? 1
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.cyan],
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
                            Image(systemName: "chevron.left")
                            // Text("Back")
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
                
                Text("Reaction Time History")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                if data.isEmpty {
                    Text("No data available yet")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                } else {
                    Chart {
                        ForEach(data.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Time", data[index].date),
                                y: .value("Time (s)", data[index].score)
                            )
                            .foregroundStyle(.yellow)
                        }
                    }
                    .chartYScale(domain: (minScore * 0.9)...(maxScore * 1.1))
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel(centered: false, anchor: .top) {
                                if let date = value.as(Date.self) {
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.hour, .minute, .month, .day], from: date)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0))
                                            .font(.caption)
                                        Text(String(format: "%02d/%02d", components.month ?? 0, components.day ?? 0))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) {
                            AxisValueLabel()
                        }
                    }
                    .foregroundStyle(.white)
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            var tempData: [(Date, Double)] = []
            
            for line in lines.dropFirst() { // Skip header
                let parts = line.components(separatedBy: ",")
                if parts.count >= 4 && parts[1].trimmingCharacters(in: .whitespaces) == "Reaction" {
                    if let date = dateFormatter.date(from: parts[0]),
                       let score = Double(parts[3]) {
                        tempData.append((date, score))
                    }
                }
            }
            
            data = tempData.sorted { $0.0 < $1.0 }
        } catch {
            print("Error loading stats.csv: \(error)")
        }
    }
}

// MARK: - Preview
struct ReactionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionGraphView()
    }
}
