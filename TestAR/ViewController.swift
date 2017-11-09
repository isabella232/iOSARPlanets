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
    
    private let systemSize: Float = 6
    private let planetSize: Float = 0.15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X

        let sunNode = createPlanet(planet: Planet.SUN, planetScale: planetSize, systemScale: systemSize)
        createSatellites(parentPlanet: Planet.SUN, parentNode: sunNode, planetScale: planetSize, systemScale: systemSize)
        
        let planetScene = SCNScene()
        planetScene.rootNode.addChildNode(sunNode)
        
        // Set the scene to the view
        sceneView.scene = planetScene
        sceneView.scene.rootNode.position = SCNVector3Make(0, -3, 0)
    }
    
    fileprivate func createSatellites(parentPlanet: Planet, parentNode: SCNNode, planetScale: Float, systemScale: Float) {
        let surfaceRadius = parentPlanet.scaledRadius(planetSize: planetSize)
        
        for child in parentPlanet.children {
            let node = createPlanet(planet: child, planetScale: planetScale, systemScale: systemScale)
            
            createSatellites(parentPlanet: child, parentNode: node, planetScale: planetScale, systemScale: systemScale)
            
            let offset = child.scaledOrbit(solarSystemSize: systemSize) + surfaceRadius
            node.position = SCNVector3Make(0, 0, -offset)
            
            parentNode.addChildNode(node)
        }
    }
    
    fileprivate func createPlanet(planet: Planet, planetScale: Float, systemScale: Float) -> SCNNode {
        let material = SCNMaterial()
        material.name = planet.name
        material.diffuse.contents = planet.image
        
        let sphere = SCNNode(geometry: SCNSphere(radius: CGFloat(planet.scaledRadius(planetSize: planetScale))))
        sphere.geometry?.materials = [material]
        
        return sphere
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
