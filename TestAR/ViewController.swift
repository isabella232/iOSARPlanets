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
    
    private let systemSize: Float = 24
    private let planetSize: Float = 0.1
    private let timeScale: Float = 240

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X

        let planetScene = SCNScene()
        
        let sunNode = createPlanet(planet: Planet.SUN, planetScale: planetSize, systemScale: systemSize)
        planetScene.rootNode.addChildNode(sunNode)
        Planet.SUN.node = planetScene.rootNode
        
        createSatellites(parentPlanet: Planet.SUN, parentNode: planetScene.rootNode, planetScale: planetSize, systemScale: systemSize)
        animate(planet: Planet.SUN, timeScale: timeScale)
        
        // Set the scene to the view
        sceneView.scene = planetScene
        sceneView.scene.rootNode.position = SCNVector3Make(0, -3, 0)
        sceneView.scene.background.contents = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    fileprivate func animate(planet: Planet, timeScale: Float) {
        if let orbitNode = planet.node {
            let animation = createOrbitAnimation(planet: planet, timeScale: timeScale)
            orbitNode.addAnimation(animation, forKey: "ORBIT")
        }
        if let comNode = planet.node?.childNode(withName: "\(planet.name)_Surface", recursively: true) {
            let animation = createRotationAnimation(planet: planet, timeScale: timeScale/365)
            comNode.addAnimation(animation, forKey: "ROTATION")
        }
        
        for child in planet.children {
            animate(planet: child, timeScale: timeScale)
        }
    }
    
    fileprivate func createOrbitAnimation(planet: Planet, timeScale: Float) -> CABasicAnimation {
        let orbit = CABasicAnimation(keyPath: "rotation")
        orbit.fromValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0))
        orbit.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float.pi * 2))
        orbit.duration = planet.scaledOrbitPeriod(timeScale: timeScale)
        orbit.repeatCount = .infinity
        
        return orbit
    }
    
    fileprivate func createRotationAnimation(planet: Planet, timeScale: Float) -> CABasicAnimation {
        let orbit = CABasicAnimation(keyPath: "rotation")
        orbit.fromValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0))
        orbit.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float.pi * 2))
        orbit.duration = planet.scaledRotationPeriod(timeScale: timeScale)
        orbit.repeatCount = .infinity
        
        return orbit
    }
    
    fileprivate func createSatellites(parentPlanet: Planet, parentNode: SCNNode, planetScale: Float, systemScale: Float) {
        let scaledSurface = parentPlanet.scaledRadius(planetSize: planetScale)
        
        for child in parentPlanet.children {
            // Node representing center of mass for planet
            let massNode = createPlanet(planet: child, planetScale: planetScale, systemScale: systemScale)
            
            // Position away from parent
            let offset = child.scaledOrbit(solarSystemSize: systemSize) + scaledSurface
            massNode.position = SCNVector3Make(0, 0, -offset)
            
            // Create node for rotating to emmulate "orbiting"
            let orbitNode = SCNNode()
            orbitNode.name = "\(child.name)_Orbit"
            orbitNode.addChildNode(massNode)
            child.node = orbitNode
            
            parentNode.addChildNode(orbitNode)
            
            createSatellites(parentPlanet: child, parentNode: massNode, planetScale: planetScale, systemScale: systemScale)
        }
    }
    
    fileprivate func createPlanet(planet: Planet, planetScale: Float, systemScale: Float) -> SCNNode {
        let scaledRadius = planet.scaledRadius(planetSize: planetScale)
        
        let material = SCNMaterial()
        material.name = planet.name
        material.diffuse.contents = planet.image
        
        let centerOfMass = SCNNode()
        centerOfMass.name = "\(planet.name)_CoM"
        
        let textGeometry = SCNText(string: planet.name, extrusionDepth: 0.1)
        textGeometry.flatness = 0.1
        
        let text = SCNNode(geometry: textGeometry)
        text.position = SCNVector3Make(0, scaledRadius + 0.01, 0)
        text.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        // Make the text anchor point center bottom
        let (textMin, textMax) = textGeometry.boundingBox
        text.pivot = SCNMatrix4MakeTranslation(textMin.x + (textMax.x - textMin.x) * 0.5, 0, 0)
        
        // We can not put the billboard constraint directly onto a text node
        // Because Apple is broken
        // So this parent node only exists to hold the constraint
        let textParentNode = SCNNode()
        textParentNode.addChildNode(text)
        
        let directionConstraint = SCNBillboardConstraint()
        textParentNode.constraints = [directionConstraint]
        
        centerOfMass.addChildNode(textParentNode)
        
        
        let sphere = SCNNode(geometry: SCNSphere(radius: CGFloat(scaledRadius)))
        sphere.geometry?.materials = [material]
        sphere.name = "\(planet.name)_Surface"
        
        centerOfMass.addChildNode(sphere)
        return centerOfMass
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
