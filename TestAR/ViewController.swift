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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private let scaleSpace: Double = 0.00000000001
    private let scaleSize: Double = 0.000001
    private let scaleTime: Double = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X

        let planetScene = SCNScene()
        
        for planet in Planet.ALL_PLANETS {
            let material = SCNMaterial()
            material.name = planet.name
            material.diffuse.contents = planet.image
            
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.2))
            sphere.geometry?.materials = [material]
            sphere.position = SCNVector3Make(0, 0, (Float)(planet.orbitRadius * scaleSpace))
            
            planetScene.rootNode.addChildNode(sphere)
        }
        
        // Set the scene to the view
        sceneView.scene = planetScene
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
