//
//  ScenePlanet.swift
//  TestAR
//
//  Created by Justin Reid on 11/17/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import ARKit

/// Representation of a Planet that has been placed in the scene
class ScenePlanet {
    /// The planet data
    let planet: Planet
    
    var rootNode: SCNNode = SCNNode()
    var planetNode: SCNNode = SCNNode()
        
    init(baseData: Planet, planetScale: Float) {
        planet = baseData
        rootNode = SCNNode()
        rootNode.name = planet.name
        
        planetNode = createPlanetBody(planetData: planet)
        
        rootNode.addChildNode(planetNode)
        rootNode.addChildNode(createTappableArea())
        
        setScale(planetScale)
    }
    
    fileprivate func createTappableArea() -> SCNNode {
        let material = SCNMaterial()
        material.name = "tap"
        material.diffuse.contents = UIColor.clear
        
        let tapGeom = SCNPlane(width: 0.5, height: 0.5)
        tapGeom.materials = [material]
        
        let tapNode = SCNNode(geometry: tapGeom)
        
        // We can not put the billboard constraint directly onto a text node
        // Because Apple is broken
        // So this parent node only exists to hold the constraint
        let tapParentNode = SCNNode()
        tapParentNode.addChildNode(tapNode)
        
        let directionConstraint = SCNBillboardConstraint()
        tapParentNode.constraints = [directionConstraint]
        
        return tapParentNode
    }
    
    fileprivate func createPlanetBody(planetData: Planet) -> SCNNode {
        let material = SCNMaterial()
        material.name = planet.name
        material.diffuse.contents = planet.image
        
        let sphere = SCNNode(geometry: SCNSphere(radius: 1))
        sphere.geometry?.materials = [material]
        
        return sphere
    }
    
    func setScale(_ planetScale: Float) {
        let scaledRadius = planet.scaledRadius(planetSize: planetScale)
        planetNode.scale = SCNVector3Make(scaledRadius, scaledRadius, scaledRadius)
    }
}
