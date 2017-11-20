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
    
    private let systemSize: Float = 24
    private let planetSize: Float = 0.1
    private let timeScale: Float = 240
    
    private var sceneManager: SceneManager?
    
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

        for location in iconLocations {
            let node = SKShapeNode(circleOfRadius: 10)
            node.position = CGPoint(x: location.x, y: skScene.size.height - location.y)
            
            //let radius: CGFloat = 10.0
            //node.path = UIBezierPath(roundedRect: CGRect(x: -radius, y: -radius, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
            node.strokeColor = UIColor.white
            node.fillColor = UIColor.clear
            node.lineWidth = 1

            skScene.addChild(node)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        sceneView.scene.background.contents = [#imageLiteral(resourceName: "GalaxyTex_PositiveX.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeX.jpeg"),#imageLiteral(resourceName: "GalaxyTex_PositiveY.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeY.jpeg"),#imageLiteral(resourceName: "GalaxyTex_PositiveZ.jpeg"),#imageLiteral(resourceName: "GalaxyTex_NegativeZ.jpeg")]
        sceneView.scene.rootNode.addChildNode(manager.rootNode)
        sceneView.overlaySKScene = SKScene(size: sceneView.frame.size)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
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
        
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return
        }
        
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let offset = SCNVector3Make(cameraPosition.x - node.position.x, cameraPosition.y - node.position.y, cameraPosition.z - node.position.z)
        
        manager.centerSystem(focusName: name, newCenter: offset)
        manager.systemSize *= 10
        manager.planetSize *= 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
