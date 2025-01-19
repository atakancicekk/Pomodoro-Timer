//
//  ContentView.swift
//  Pomodoro Timer
//
//  Created by Atakan Cicek on 9.01.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var currentMode: TimerMode = .shortBreak
    @State private var completedSessions = 0
    @State private var progress: Double = 1.0  // Represents progress from 1.0 to 0.0
    @State private var showingCompletionAlert = false
    @State private var completionMessage = ""
    
    // Initialize timeRemaining with the current mode's duration
    init() {
        _timeRemaining = State(initialValue: TimerMode.shortBreak.duration)
    }
    
    enum TimerMode: Hashable {
        case work
        case shortBreak
        case longBreak
        
        var buttonTitle: String {
            switch self {
            case .work: return "Work"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
        
        var title: String {
            switch self {
            case .work: return "Work Session"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
        
        var duration: Int {
            switch self {
            case .work: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
        
        var color: Color {
            switch self {
            case .work: return .blue
            case .shortBreak: return .green
            case .longBreak: return .purple
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Mode Selection Buttons
            HStack(spacing: 20) {
                ForEach([TimerMode.work, .shortBreak, .longBreak], id: \.self) { mode in
                    Button(action: { switchMode(to: mode) }) {
                        Text(mode.buttonTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(currentMode == mode ? 
                                        mode.color.opacity(0.2) : 
                                        Color.gray.opacity(0.1))
                            )
                            .foregroundStyle(currentMode == mode ? 
                                mode.color : 
                                Color.gray)
                    }
                }
            }
            
            // Timer Mode Label
            Text(currentMode.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(currentMode.color)
            
            // Timer Circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundStyle(currentMode.color.opacity(0.3))
                
                Circle()
                    .trim(from: 1 - progress, to: 1)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .foregroundStyle(currentMode.color)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.25), value: progress)
                
                VStack {
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    // Add mode indicator
                    Text(currentMode.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 300, height: 300)
            
            // Control Buttons
            HStack(spacing: 30) {
                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                        .foregroundStyle(currentMode.color)
                }
                .frame(width: 80, height: 80)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                
                Button(action: toggleTimer) {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(width: 80, height: 80)
                .background(isActive ? Color.red : currentMode.color)
                .clipShape(Circle())
            }
            
            // Session Progress with visual indicators
            VStack(spacing: 8) {
                Text("Work sessions completed: \(completedSessions)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .animation(.easeInOut, value: currentMode)
        .alert("Session Complete!", isPresented: $showingCompletionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(completionMessage)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func toggleTimer() {
        if isActive {
            stopTimer()
        } else {
            startTimer()
        }
        isActive.toggle()
    }
    
    private func startTimer() {
        let duration = TimeInterval(timeRemaining)
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let elapsedTime = Date().timeIntervalSince(startTime)
            let remainingTime = duration - elapsedTime
            
            if remainingTime > 0 {
                timeRemaining = Int(ceil(remainingTime))
                progress = remainingTime / duration
            } else {
                progress = 0
                stopTimer()
                handleTimerCompletion()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        isActive = false
        timeRemaining = currentMode.duration
        progress = 1.0
    }
    
    private func handleTimerCompletion() {
        stopTimer()
        isActive = false
        
        if currentMode == .work || currentMode == .shortBreak || currentMode == .longBreak {
            completedSessions += 1  // Only increment for work sessions
        }
        
        // Set completion message after updating the counter
        switch currentMode {
        case .work:
            completionMessage = "Great job! You've completed work session #\(completedSessions)! 💪"
        case .shortBreak:
            completionMessage = "Break time is over! Ready to focus again? 🎯"
        case .longBreak:
            completionMessage = "Long break finished! Time to get back to work! 🌟"
        }
        
        showingCompletionAlert = true
        timeRemaining = currentMode.duration
        progress = 1.0
    }
    
    private func switchMode(to newMode: TimerMode) {
        stopTimer()
        isActive = false
        currentMode = newMode
        timeRemaining = newMode.duration
        progress = 1.0
    }
}

#Preview {
    ContentView()
}
