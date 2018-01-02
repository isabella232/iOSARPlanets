//
//  ViewController.swift
//  TestAR
//
//  Created by Justin Reid on 8/22/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var focusLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    private var sceneManager: SceneManager?
    
    private let timeScales: [Float] = [1, 2, 3, 5, 10, 50, 100, 1000, 10000, 100000, 1000000, 10000000]
    private var currentTimeScale = 5
    
    @IBAction func increaseTime() {
        guard let manager = sceneManager else {
            return
        }
        currentTimeScale = min(currentTimeScale + 1, timeScales.count - 1)
        manager.timeScale = timeScales[currentTimeScale]
        
        updateTimeLabel()
    }
    @IBAction func decreaseTime() {
        guard let manager = sceneManager else {
            return
        }
        currentTimeScale = max(currentTimeScale - 1, 0)
        manager.timeScale = timeScales[currentTimeScale]
        
        updateTimeLabel()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let manager = sceneManager else {
            return
        }
        
        guard let camera = sceneView.session.currentFrame?.camera else {
            return
        }
        
        guard let skScene = sceneView.overlaySKScene else {
            return
        }
        
        let iconLocations = manager.update(renderer: renderer, systemTime: time, camera: camera)
        skScene.removeAllChildren()

        for screenPlanet in iconLocations {
            let node = SKShapeNode(circleOfRadius: 10)
            node.position = CGPoint(x: screenPlanet.position.x, y: skScene.frame.size.height - screenPlanet.position.y)
            
            //let radius: CGFloat = 10.0
            //node.path = UIBezierPath(roundedRect: CGRect(x: -radius, y: -radius, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
            node.strokeColor = UIColor.white
            node.fillColor = UIColor.clear
            node.lineWidth = 1

            skScene.addChild(node)
            
            let text = SKLabelNode(text: screenPlanet.planet.name)
            text.fontSize = 12
            text.fontName = "HelveticaNeue-Bold"
            text.position = CGPoint(x: node.position.x, y: node.position.y + text.frame.height)
            skScene.addChild(text)
        }
    }

    fileprivate func updateTimeLabel() {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        
        let number = formatter.string(from: NSNumber(value: timeScales[currentTimeScale])) ?? "?"
        
        timeLabel.text = "Time: \(number)x"
    }
    
    @objc fileprivate func didTap(sender: UIGestureRecognizer) {
        let screenPoint = sender.location(ofTouch: 0, in: sceneView)
        let hitTest = sceneView.hitTest(screenPoint, options: [SCNHitTestOption.backFaceCulling: true])
        
        if hitTest.count == 0 {
            return
        }
        
        let closest = hitTest[0]
        var node = closest.node
        
        // The first name we find in the hiearchy should be a planet body name
        while(node.name == nil) {
            guard let parent = node.parent else {
                return
            }
            
            node = parent
        }
        
        guard let manager = sceneManager, let name = node.name else {
            return
        }
        
        manager.centerSystem(focusName: name)
        focusLabel.text = "Focus: \(manager.getFocusPlanet().name)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X
        
        let manager = SceneManager()
        sceneManager = manager
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
        //sceneView.scene.background.contents = [#imageLiteral(resourceName: "GalaxyTex_PositiveX.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeX.jpeg"),#imageLiteral(resourceName: "GalaxyTex_PositiveY.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeY.jpeg"),#imageLiteral(resourceName: "GalaxyTex_PositiveZ.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeZ.jpeg")]
        sceneView.scene.rootNode.addChildNode(manager.rootNode)
        sceneView.overlaySKScene = SKScene(size: sceneView.frame.size)
        
        if let camera = sceneView.pointOfView?.camera {
            camera.zFar = 10000 // I can't use infinity :(
            camera.zNear = 0.001
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        
        updateTimeLabel()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
