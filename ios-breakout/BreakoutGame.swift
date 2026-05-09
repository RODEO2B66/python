import SwiftUI
import Combine

@main
struct BreakoutGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

struct Brick: Identifiable {
    let id = UUID()
    var rect: CGRect
    var isAlive: Bool = true
}

struct GameView: View {
    private let playSize = CGSize(width: 390, height: 640)
    private let paddleSize = CGSize(width: 86, height: 14)
    private let ballSize: CGFloat = 14

    @State private var paddleX: CGFloat = 195
    @State private var ballPosition = CGPoint(x: 195, y: 480)
    @State private var ballVelocity = CGVector(dx: 3.1, dy: -4.2)
    @State private var bricks: [Brick] = GameView.makeBricks()
    @State private var score = 0
    @State private var lives = 3
    @State private var isPaused = true

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / playSize.width, geometry.size.height / playSize.height)

            ZStack {
                Color.black.ignoresSafeArea()

                ZStack {
                    ForEach(bricks) { brick in
                        if brick.isAlive {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.cyan)
                                .frame(width: brick.rect.width, height: brick.rect.height)
                                .position(x: brick.rect.midX, y: brick.rect.midY)
                        }
                    }

                    Circle()
                        .fill(.white)
                        .frame(width: ballSize, height: ballSize)
                        .position(ballPosition)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(.orange)
                        .frame(width: paddleSize.width, height: paddleSize.height)
                        .position(x: paddleX, y: playSize.height - 50)
                }
                .frame(width: playSize.width, height: playSize.height)
                .scaleEffect(scale)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            paddleX = value.location.x / scale
                            if isPaused {
                                isPaused = false
                            }
                        }
                )
            }
            .onReceive(timer) { _ in
                if !isPaused {
                    tick()
                }
            }
        }
    }

    private func tick() {
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        if ballPosition.x < 0 || ballPosition.x > playSize.width {
            ballVelocity.dx *= -1
        }

        if ballPosition.y < 0 {
            ballVelocity.dy *= -1
        }

        let paddleRect = CGRect(x: paddleX - paddleSize.width / 2,
                                y: playSize.height - 57,
                                width: paddleSize.width,
                                height: paddleSize.height)

        let ballRect = CGRect(x: ballPosition.x - ballSize / 2,
                              y: ballPosition.y - ballSize / 2,
                              width: ballSize,
                              height: ballSize)

        if ballRect.intersects(paddleRect) {
            ballVelocity.dy = -abs(ballVelocity.dy)
        }

        for index in bricks.indices where bricks[index].isAlive {
            if ballRect.intersects(bricks[index].rect) {
                bricks[index].isAlive = false
                score += 10
                ballVelocity.dy *= -1
                break
            }
        }

        if ballPosition.y > playSize.height {
            resetGame()
        }
    }

    private func resetGame() {
        ballPosition = CGPoint(x: playSize.width / 2, y: 480)
        ballVelocity = CGVector(dx: 3.1, dy: -4.2)
        bricks = GameView.makeBricks()
        isPaused = true
    }

    static func makeBricks() -> [Brick] {
        var result: [Brick] = []
        let rows = 5
        let columns = 7
        let width: CGFloat = 42
        let height: CGFloat = 20

        for row in 0..<rows {
            for column in 0..<columns {
                result.append(
                    Brick(rect: CGRect(x: 20 + CGFloat(column) * 50,
                                       y: 80 + CGFloat(row) * 30,
                                       width: width,
                                       height: height))
                )
            }
        }

        return result
    }
}
