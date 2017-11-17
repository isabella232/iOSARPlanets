//
//  Planet.swift
//  TestAR
//
//  Created by Justin Reid on 9/1/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Planet {
    static let MERCURY = Planet(name: "Mercury", image: #imageLiteral(resourceName: "MercuryColor.png"), orbitRadius: 5.78944e10, orbitPeriod: 7.6e6, planetRadius: 2440000, planetPeriod: 5067000)
    static let VENUS = Planet(name: "Venus", image: #imageLiteral(resourceName: "VenusColor.png"), orbitRadius: 1.0771e11, orbitPeriod: 19.4e6, planetRadius: 6.052e6, planetPeriod: 10087200)
    
    static let LUNA = Planet(name: "Luna", image: #imageLiteral(resourceName: "MoonColor.png"), orbitRadius: 385000000, orbitPeriod: 2.333e+6, planetRadius: 1736482, planetPeriod: 2360448)
    static let EARTH = Planet(name: "Earth", image: #imageLiteral(resourceName: "Earth.jpg"), orbitRadius: 1.496e11, orbitPeriod: 31558118.4, planetRadius: 6371393, planetPeriod: 86164.0905,
                              children: [LUNA])
    
    
    static let DEIMOS = Planet(name: "Deimos", image: #imageLiteral(resourceName: "DeimosColor.png"), orbitRadius: 2.346E+07, orbitPeriod: 109080, planetRadius: 6600, planetPeriod: 109080)
    static let PHOBOS = Planet(name: "Phobos", image: #imageLiteral(resourceName: "PhobosColor.png"), orbitRadius: 9.376E+06, orbitPeriod: 27552, planetRadius: 11266.7, planetPeriod: 27552)
    static let MARS = Planet(name: "Mars", image: #imageLiteral(resourceName: "MarsColor.png"), orbitRadius: 228e9, orbitPeriod: 59.4e6, planetRadius: 3390000, planetPeriod: 88800,
                             children: [DEIMOS, PHOBOS])
    
    static let JUPITER = Planet(name: "Jupiter", image: #imageLiteral(resourceName: "JupiterColor.png"), orbitRadius: 778e9, orbitPeriod: 370e6, planetRadius: 69.911e6, planetPeriod: 36000)
    static let SATURN = Planet(name: "Saturn", image: #imageLiteral(resourceName: "SaturnColor.png"), orbitRadius: 1.433e12, orbitPeriod: 930e6, planetRadius: 58.232e6, planetPeriod: 36840)
    static let URANUS = Planet(name: "Uranus", image: #imageLiteral(resourceName: "UranusColor.png"), orbitRadius: 2.87e12, orbitPeriod: 2.7e9, planetRadius: 25.362e6, planetPeriod: 62040)
    static let NEPTUNE = Planet(name: "Neptune", image: #imageLiteral(resourceName: "NeptuneColor.png"), orbitRadius: 4.5029e12, orbitPeriod: 5.2e12, planetRadius: 24.622e6, planetPeriod: 57996)
    static let PLUTO = Planet(name: "Pluto", image: #imageLiteral(resourceName: "PlutoColor.png"), orbitRadius: 8.13064e12, orbitPeriod: 7820908000, planetRadius: 1.187e6, planetPeriod: 552096)
    
    static let SUN = Planet(name: "Sol", image: #imageLiteral(resourceName: "sun.jpg"), orbitRadius: 0, orbitPeriod: 0, planetRadius: 695.7e6, planetPeriod: 2.074e+6,
                            children: [MERCURY, VENUS, EARTH, MARS, JUPITER, SATURN, URANUS, NEPTUNE, PLUTO])
    
    public static let SOLAR_SYSTEM_SIZE: Double = NEPTUNE.orbitRadius
    public static let PLANET_MAX_RADIUS: Double = 69.911e6
    public static let ORBIT_TIME: Double = 365 * 24 * 60 * 60 // 1 Earth-Year
    public static let ROTATION_TIME: Double = 24 * 60 * 60 // 1 Earth-Day
    
    private(set) var name: String
    private(set) var orbitRadius: Double // Average distance from sun in meters
    private(set) var orbitPeriod: Double // Average orbit time in seconds
    private(set) var planetRadius: Double // Average planet radius in meters
    private(set) var planetPeriod: Double // Rotation on planet in seconds (a day)
    private(set) var image: UIImage?
    private(set) var children: [Planet] // Planets orbiting this body
    
    init(name: String, image: UIImage?, orbitRadius: Double, orbitPeriod: Double, planetRadius: Double, planetPeriod: Double) {
        self.name = name
        self.image = image
        self.orbitPeriod = orbitPeriod
        self.orbitRadius = orbitRadius
        self.planetPeriod = planetPeriod
        self.planetRadius = planetRadius
        self.children = []
    }
    
    init(name: String, image: UIImage?, orbitRadius: Double, orbitPeriod: Double, planetRadius: Double, planetPeriod: Double, children: [Planet]) {
        self.name = name
        self.image = image
        self.orbitPeriod = orbitPeriod
        self.orbitRadius = orbitRadius
        self.planetPeriod = planetPeriod
        self.planetRadius = planetRadius
        self.children = children
    }
    
    public func scaledOrbit(solarSystemSize: Float) -> Double {
        return (orbitRadius / Planet.SOLAR_SYSTEM_SIZE) * Double(solarSystemSize)
    }
    
    public func scaledRadius(planetSize: Float) -> Float {
        return Float((planetRadius / Planet.PLANET_MAX_RADIUS) * Double(planetSize))
    }
    
    /// Scale orbital period so that 1 Earth years orbit happens in timeScale
    public func scaledOrbitPeriod(timeScale: Float) -> Double {
        return (orbitPeriod / Planet.ORBIT_TIME) * Double(timeScale)
    }
    
    public func scaledRotationPeriod(timeScale: Float) -> Double {
        return (planetPeriod / Planet.ROTATION_TIME) * Double(timeScale)
    }
}
