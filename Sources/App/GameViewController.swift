import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // Create the view as an SKView from code — no storyboard needed
    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif

        skView.ignoresSiblingOrder = true

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
