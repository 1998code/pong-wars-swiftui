//
//  ContentView.swift
//  Pong Wars
//
//  Created by Ming on 24/5/2025. Inspired by vnglst.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = PongWarsGameModel()
    @State private var timer: Timer?
    @State private var gridSize: Int = 10                   // Default grid size (10x10)
    @State private var isFullScreen: Bool = false           // Track fullscreen state
    @State private var gameSpeed: Double = 1.0              // Default speed multiplier
    @State private var dayColor = Color(hex: "#114C5A")
    @State private var nightColor = Color(hex: "#D9E8E3")
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                ZStack {
                    // Game canvas
                    GameCanvas(gameModel: gameModel)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(4)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isFullScreen.toggle()
                            }
                        }
                }
                
                if !isFullScreen {
                    // Score display
                    HStack {
                        ColorPicker("", selection: $dayColor)
                            .labelsHidden()
                            .onChange(of: dayColor) {_,  newValue in
                                updateDayBallColor(newValue)
                            }
                        
                        Text("Day **\(gameModel.dayScore)** vs Night **\(gameModel.nightScore)**")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color(hex: "#172b36"))
                        
                        ColorPicker("", selection: $nightColor)
                            .labelsHidden()
                            .onChange(of: nightColor) {_,  newValue in
                                updateNightBallColor(newValue)
                            }
                    }.padding(.top, 30)
                    
                    Spacer()
                    
                    // Controls section
                    VStack(spacing: 20) {
                        // Grid size control
                        VStack {
                            Text("Grid Size: \(gridSize)×\(gridSize)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color(hex: "#172b36"))
                            
                            Slider(value: Binding(
                                get: { Double(gridSize) },
                                set: { newValue in
                                    gridSize = Int(newValue)
                                    gameModel.resetWithGridSize(gridSize)
                                }
                            ), in: 10...40)
                            .accentColor(Color(hex: "#114C5A"))
                            .padding(.horizontal)
                        }
                        
                        // Speed control
                        VStack {
                            Text("Game Speed: \(String(format: "%.1fx", gameSpeed))")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color(hex: "#172b36"))
                            
                            Slider(value: $gameSpeed, in: 0.5...100.0)
                                .accentColor(Color(hex: "#114C5A"))
                                .padding(.horizontal)
                                .onChange(of: gameSpeed) {_,  newValue in
                                    updateGameSpeed()
                                }
                        }
                    }
                    
                    Spacer()
                    
                    // Attribution
                    VStack(spacing: 5) {
                        Text("Made by MING | SwiftUI Version")
                            .font(.system(size: 10, design: .monospaced))
                        Text("Available on github")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(Color(hex: "#172b36"))
                    .padding(.vertical, 20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [dayColor, nightColor]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Fullscreen overlay
            if isFullScreen {
                // Floating score display in fullscreen mode
                VStack {
                    HStack {
                        Text("🌞 Day \(gameModel.dayScore) vs Night \(gameModel.nightScore) 🌝")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isFullScreen = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(8)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startGameTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / (60.0 * gameSpeed), repeats: true) { _ in
            gameModel.update()
        }
    }
    
    private func updateGameSpeed() {
        // Stop current timer
        timer?.invalidate()
        // Start a new timer with the updated speed
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / (60.0 * gameSpeed), repeats: true) { _ in
            gameModel.update()
        }
    }

    // Color update functions
    private func updateDayColor(_ color: Color) {
        let hexString = color.toHex() ?? "#D9E8E3"
        gameModel.updateDayColor(hexString)
    }
    
    private func updateDayBallColor(_ color: Color) {
        let hexString = color.toHex() ?? "#114C5A"
        gameModel.updateDayBallColor(hexString)
    }
    
    private func updateNightColor(_ color: Color) {
        let hexString = color.toHex() ?? "#172B36"
        gameModel.updateNightColor(hexString)
    }
    
    private func updateNightBallColor(_ color: Color) {
        let hexString = color.toHex() ?? "#D9E8E3"
        gameModel.updateNightBallColor(hexString)
    }
}

// Color extension to handle hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

// Game Canvas that renders the game state
struct GameCanvas: View {
    @ObservedObject var gameModel: PongWarsGameModel
    
    var body: some View {
        Canvas { context, size in
            // Draw squares
            for i in 0..<gameModel.numSquaresX {
                for j in 0..<gameModel.numSquaresY {
                    let squareSize = size.width / CGFloat(gameModel.numSquaresX)
                    let rect = CGRect(
                        x: CGFloat(i) * squareSize,
                        y: CGFloat(j) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    
                    let color = gameModel.squares[i][j] == gameModel.dayColor ? 
                        Color(hex: gameModel.dayColor) : Color(hex: gameModel.nightColor)
                    
                    context.fill(Path(rect), with: .color(color))
                }
            }
            
            // Draw balls
            for ball in gameModel.balls {
                let squareSize = size.width / CGFloat(gameModel.numSquaresX)
                let radius = squareSize / 2
                
                let ballX = CGFloat(ball.x) / CGFloat(gameModel.canvasWidth) * size.width
                let ballY = CGFloat(ball.y) / CGFloat(gameModel.canvasHeight) * size.height
                
                let circlePath = Path(ellipseIn: CGRect(
                    x: ballX - radius,
                    y: ballY - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                
                context.fill(circlePath, with: .color(Color(hex: ball.ballColor)))
            }
        }
        .background(Color.white.opacity(0.01)) // Tiny bit of background to make canvas tappable
    }
}

// Game model that manages the game state
class PongWarsGameModel: ObservableObject {
    // Colors from the original
    @Published var dayColor = "#D9E8E3"
    @Published var dayBallColor = "#114C5A"
    @Published var nightColor = "#172B36"
    @Published var nightBallColor = "#D9E8E3"
    
    // Game constants
    var squareSize: Int
    let minSpeed: Double = 5
    let maxSpeed: Double = 10
    let canvasWidth = 600
    let canvasHeight = 600
    
    var numSquaresX: Int
    var numSquaresY: Int
    
    @Published var dayScore = 0
    @Published var nightScore = 0
    @Published var squares: [[String]]
    @Published var balls: [Ball] = [] // Initialize with empty array first
    
    struct Ball {
        var x: Double
        var y: Double
        var dx: Double
        var dy: Double
        var reverseColor: String
        var ballColor: String
    }
    
    init() {
        numSquaresX = 10 // Default grid size
        numSquaresY = 10
        squareSize = canvasWidth / numSquaresX
        
        // Initialize squares
        squares = Array(repeating: Array(repeating: "", count: numSquaresY), count: numSquaresX)
        initializeSquares()
        initializeBalls()
    }
    
    private func initializeSquares() {
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                squares[i][j] = i < numSquaresX / 2 ? dayColor : nightColor
            }
        }
    }
    
    private func initializeBalls() {
        balls = [
            Ball(
                x: Double(canvasWidth) / 4,
                y: Double(canvasHeight) / 2,
                dx: 8,
                dy: -8,
                reverseColor: dayColor,
                ballColor: dayBallColor
            ),
            Ball(
                x: Double(canvasWidth) * 3 / 4,
                y: Double(canvasHeight) / 2,
                dx: -8,
                dy: 8,
                reverseColor: nightColor,
                ballColor: nightBallColor
            )
        ]
    }
    
    func resetWithGridSize(_ size: Int) {
        numSquaresX = size
        numSquaresY = size
        squareSize = canvasWidth / numSquaresX
        
        // Reinitialize squares with new size
        squares = Array(repeating: Array(repeating: "", count: numSquaresY), count: numSquaresX)
        initializeSquares()
        initializeBalls()
    }
    
    func update() {
        updateScores()
        
        // Update each ball
        for i in 0..<balls.count {
            checkSquareCollision(for: &balls[i])
            checkBoundaryCollision(for: &balls[i])
            
            // Move ball
            balls[i].x += balls[i].dx
            balls[i].y += balls[i].dy
            
            // Add randomness
            addRandomness(to: &balls[i])
        }
    }
    
    private func updateScores() {
        dayScore = 0
        nightScore = 0
        
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == dayColor {
                    dayScore += 1
                } else if squares[i][j] == nightColor {
                    nightScore += 1
                }
            }
        }
    }
    
    private func checkSquareCollision(for ball: inout Ball) {
        // Check multiple points around the ball's circumference
        for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 4) {
            let checkX = ball.x + cos(angle) * Double(squareSize / 2)
            let checkY = ball.y + sin(angle) * Double(squareSize / 2)
            
            let i = Int(checkX) / squareSize
            let j = Int(checkY) / squareSize
            
            if i >= 0 && i < numSquaresX && j >= 0 && j < numSquaresY {
                if squares[i][j] != ball.reverseColor {
                    // Square hit! Update square color
                    squares[i][j] = ball.reverseColor
                    
                    // Determine bounce direction based on the angle
                    if abs(cos(angle)) > abs(sin(angle)) {
                        ball.dx = -ball.dx
                    } else {
                        ball.dy = -ball.dy
                    }
                }
            }
        }
    }
    
    private func checkBoundaryCollision(for ball: inout Ball) {
        let radius = Double(squareSize) / 2
        if ball.x + ball.dx > Double(canvasWidth) - radius || ball.x + ball.dx < radius {
            ball.dx = -ball.dx
        }
        if ball.y + ball.dy > Double(canvasHeight) - radius || ball.y + ball.dy < radius {
            ball.dy = -ball.dy
        }
    }
    
    private func addRandomness(to ball: inout Ball) {
        ball.dx += Double.random(in: -0.01...0.01)
        ball.dy += Double.random(in: -0.01...0.01)
        
        // Limit the speed of the ball
        ball.dx = min(max(ball.dx, -maxSpeed), maxSpeed)
        ball.dy = min(max(ball.dy, -maxSpeed), maxSpeed)
        
        // Make sure the ball always maintains a minimum speed
        if abs(ball.dx) < minSpeed {
            ball.dx = ball.dx > 0 ? minSpeed : -minSpeed
        }
        if abs(ball.dy) < minSpeed {
            ball.dy = ball.dy > 0 ? minSpeed : -minSpeed
        }
    }
    
    func updateDayColor(_ newColor: String) {
        // Update all squares with the old day color
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == dayColor {
                    squares[i][j] = newColor
                }
            }
        }
        
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].reverseColor == dayColor {
                balls[i].reverseColor = newColor
            }
        }
        
        dayColor = newColor
    }
    
    func updateDayBallColor(_ newColor: String) {
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].ballColor == dayBallColor {
                balls[i].ballColor = newColor
            }
        }
        
        dayBallColor = newColor
    }
    
    func updateNightColor(_ newColor: String) {
        // Update all squares with the old night color
        for i in 0..<numSquaresX {
            for j in 0..<numSquaresY {
                if squares[i][j] == nightColor {
                    squares[i][j] = newColor
                }
            }
        }
        
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].reverseColor == nightColor {
                balls[i].reverseColor = newColor
            }
        }
        
        nightColor = newColor
    }
    
    func updateNightBallColor(_ newColor: String) {
        // Update any balls using this color
        for i in 0..<balls.count {
            if balls[i].ballColor == nightBallColor {
                balls[i].ballColor = newColor
            }
        }
        
        nightBallColor = newColor
    }
}

#Preview {
    ContentView()
}
