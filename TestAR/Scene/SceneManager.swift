//
//  SceneManager.swift
//  TestAR
//
//  Created by Justin Reid on 11/17/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class SceneManager {
    private var _systemSize: Float = 24
    private var _planetSize: Float = 0.01
    private var _timeScale: Float = 120
    
    /// How far from origin should the focus planet be
    private var offset = SCNVector3Make(0, 0, 0)
    /// Which planet should be at the origin
    private var focusPlanet: ScenePlanet?
    private var planetMap: [String:ScenePlanet]
    
    public let rootNode: SCNNode
    
    init() {
        planetMap = [:]
        rootNode = SCNNode()
        
        /// Build all planet nodes
        createScenePlanet(planet: Planet.SUN, sceneRoot: rootNode)
    }
    
    fileprivate func createScenePlanet(planet: Planet, sceneRoot: SCNNode) {
        let scenePlanet = ScenePlanet(baseData: planet, planetScale: planetSize)
        sceneRoot.addChildNode(scenePlanet.rootNode)
        
        planetMap[planet.name] = scenePlanet
        
        for child in planet.children {
            createScenePlanet(planet: child, sceneRoot: sceneRoot)
        }
    }
    
    /// The radius of the solar system orbit distances, in meters.
    var systemSize: Float {
        set(newSize) {
            _systemSize = newSize
        }
        get {
            return _systemSize
        }
    }
    
    /// The radius of Jupiter, in meters. The other planets will be to-scale.
    var planetSize: Float {
        set(newSize) {
            _planetSize = newSize
        }
        get {
            return _planetSize
        }
    }
    
    /// One year in seconds.
    var timeScale: Float {
        set(newSize) {
            _timeScale = newSize
        }
        get {
            return _timeScale
        }
    }
    
    /// The planet to focus on, and how far away to place that planet after all scaling shenanigans are done
    public func centerSystem(focusName: String, newCenter: SCNVector3) {
        guard let focusScenePlanet = planetMap[focusName] else {
            return
        }
        
        focusPlanet = focusScenePlanet
        offset = focusScenePlanet.rootNode.worldPosition
    }
    
    /// Update the scene
    public func update(renderer: SCNSceneRenderer, systemTime: TimeInterval, camera: ARCamera) -> [CGPoint] {
        guard let rootScenePlanet = planetMap[Planet.SUN.name] else {
            return []
        }
        
        // Position all planets based on 0,0,0
        let scaledTime = systemTime * (Planet.ORBIT_TIME / Double(timeScale))
        positionPlanet(scenePlanet: rootScenePlanet, atRealTime: scaledTime, parentPos: SCNVector3Make(0,0,0))
        
        // Move planets to focus on one
        guard let focusScenePlanet = focusPlanet ?? planetMap[Planet.SUN.name] else {
            return []
        }
        
        let focusOffset = SCNVector3Make(-focusScenePlanet.rootNode.worldPosition.x, -focusScenePlanet.rootNode.worldPosition.y, -focusScenePlanet.rootNode.worldPosition.z)
        let totalOffset = SCNVector3Make(focusOffset.x + offset.x, focusOffset.y + offset.y, focusOffset.z + offset.z)
        
        for scenePlanet in planetMap.values {
            scenePlanet.rootNode.localTranslate(by: totalOffset)
        }
        
        guard let pov = renderer.pointOfView else {
            return []
        }
        
        // Move icons
        var iconPoints:[CGPoint] = []
        for scenePlanet in planetMap.values {
            if(renderer.isNode(scenePlanet.rootNode, insideFrustumOf: pov)) {
                let v = renderer.projectPoint(scenePlanet.rootNode.worldPosition)
                let p = CGPoint(x: CGFloat(v.x), y: CGFloat(v.y))
                
                // Don't add points behind the camera
                if(v.z > 0) {
                    iconPoints.append(p)
                }
            }
        }
        
        return iconPoints
    }
    
    fileprivate func positionPlanet(scenePlanet: ScenePlanet, atRealTime: TimeInterval, parentPos: SCNVector3) {
        let orbitsCompleted: Double
        if(scenePlanet.planet.orbitPeriod > 0) {
            orbitsCompleted = atRealTime / scenePlanet.planet.orbitPeriod
        } else {
            orbitsCompleted = 0
        }
        
        let orbitAngle = Double.pi * 2 * orbitsCompleted
        
        let scaledDistance = scenePlanet.planet.scaledOrbit(solarSystemSize: systemSize)
        let scaledLocalPos = SCNVector3Make(Float(scaledDistance * cos(orbitAngle)), 0, Float(scaledDistance * sin(orbitAngle)))
        let scaledPos = SCNVector3Make(scaledLocalPos.x + parentPos.x, scaledLocalPos.y + parentPos.y, scaledLocalPos.z + parentPos.z)

        let rotationCompleted = atRealTime / scenePlanet.planet.planetPeriod
        let rotationAngle = Double.pi * 2 * rotationCompleted
        
        scenePlanet.rootNode.position = scaledPos
        scenePlanet.planetNode.rotation = SCNVector4Make(0, -1, 0, Float(rotationAngle))
        scenePlanet.setScale(planetSize)
        
        // Position satellites
        for child in scenePlanet.planet.children {
            if let scenePlanet = planetMap[child.name] {
                positionPlanet(scenePlanet: scenePlanet, atRealTime: atRealTime, parentPos: scaledPos)
            }
        }
    }
}
