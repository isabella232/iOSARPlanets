//
//  Planet.swift
//  TestAR
//
//  Created by Justin Reid on 9/1/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import UIKit

class Planet {
    static let SUN = Planet(name: "Sol", image: nil, orbitRadius: 0, orbitPeriod: 0, planetRadius: 695700000, planetPeriod: 0, parent: nil)
    static let EARTH = Planet(name: "Earth", image: #imageLiteral(resourceName: "Earth.jpg"), orbitRadius: 149600000000, orbitPeriod: 31558118.4, planetRadius: 6371393, planetPeriod: 86164.0905, parent: SUN)
    static let MARS = Planet(name: "Mars", image: #imageLiteral(resourceName: "MarsColor.png"), orbitRadius: 228000000000, orbitPeriod: 5.936e+7, planetRadius: 3390000, planetPeriod: 88800, parent: SUN)
    
    static let ALL_PLANETS: [Planet] = [SUN, EARTH, MARS]
    
    private(set) var name: String
    private(set) var orbitRadius: Double
    private(set) var orbitPeriod: Double
    private(set) var planetRadius: Double
    private(set) var planetPeriod: Double
    private(set) var parent: Planet?
    private(set) var image: UIImage?
    
    init(name: String, image: UIImage?, orbitRadius: Double, orbitPeriod: Double, planetRadius: Double, planetPeriod: Double, parent: Planet?) {
        self.name = name
        self.image = image
        self.orbitPeriod = orbitPeriod
        self.orbitRadius = orbitRadius
        self.planetPeriod = planetPeriod
        self.planetRadius = planetRadius
        self.parent = parent
    }
}
