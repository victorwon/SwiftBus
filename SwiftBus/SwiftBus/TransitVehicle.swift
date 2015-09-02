//
//  TransitVehicle.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

private let kVehicleIdEncoderString = "kVehicleIdEncoder"
private let kDirectionTagEncoderString = "kDirectionTagEncoder"
private let kLatEncoderString = "kLatEncoder"
private let kLonEncoderString = "kLonEncoder"
private let kSecondsSinceReportEncoderString = "kSecondsSinceReportEncoder"
private let kLeadingVehicleIdEncoderString = "kKeadingVehicleIdEncoder"
private let kHeadingEncoderString = "kHeadingEncoder"
private let kSpeedKmHEncoderString = "kSpeedKmHEncoder"

class TransitVehicle:NSObject, NSCoding {
    
    var vehicleId:Int = 0
    var directionTag:String = ""
    var lat:Double = 0
    var lon:Double = 0
    var secondsSinceReport:Int = 0
    var leadingVehicleId:Int = 0
    var heading:Int = 0
    var speedKmH:Int = 0
    
    //Basic init
    override init() { super.init() }
    
    //Init with proper things as Ints and Doubles
    init(vehicleId:Int, directionTag:String, lat:Double, lon:Double, secondsSinceReport:Int, heading:Int, speedKmH:Int) {
        self.vehicleId = vehicleId
        self.directionTag = directionTag
        self.lat = lat
        self.lon = lon
        self.secondsSinceReport = secondsSinceReport
        self.heading = heading
        self.speedKmH = speedKmH
    }
    
    //Init with everything as string, convert in init
    init(vehicleID:String, directionTag:String, lat:String, lon:String, secondsSinceReport:String, heading:String, speedKmH:String) {
        self.vehicleId = vehicleID.toInt()!
        self.directionTag = directionTag
        self.lat = (lat as NSString).doubleValue
        self.lon = (lon as NSString).doubleValue
        self.secondsSinceReport = secondsSinceReport.toInt()!
        self.heading = heading.toInt()!
        self.speedKmH = speedKmH.toInt()!
    }
    
    //MARK : NSCoding
    
    required init(coder aDecoder: NSCoder) {
        vehicleId = aDecoder.decodeObjectForKey(kVehicleIdEncoderString) as! Int
        directionTag = aDecoder.decodeObjectForKey(kDirectionTagEncoderString) as! String
        lat = aDecoder.decodeDoubleForKey(kLatEncoderString)
        lon = aDecoder.decodeDoubleForKey(kLonEncoderString)
        secondsSinceReport = aDecoder.decodeObjectForKey(kSecondsSinceReportEncoderString) as! Int
        leadingVehicleId = aDecoder.decodeObjectForKey(kLeadingVehicleIdEncoderString) as! Int
        heading = aDecoder.decodeObjectForKey(kHeadingEncoderString) as! Int
        speedKmH = aDecoder.decodeObjectForKey(kSpeedKmHEncoderString) as! Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(vehicleId, forKey: kVehicleIdEncoderString)
        aCoder.encodeObject(directionTag, forKey: kDirectionTagEncoderString)
        aCoder.encodeDouble(lat, forKey: kLatEncoderString)
        aCoder.encodeDouble(lon, forKey: kLonEncoderString)
        aCoder.encodeObject(secondsSinceReport, forKey: kSecondsSinceReportEncoderString)
        aCoder.encodeObject(leadingVehicleId, forKey: kLeadingVehicleIdEncoderString)
        aCoder.encodeObject(heading, forKey: kHeadingEncoderString)
        aCoder.encodeObject(speedKmH, forKey: kSpeedKmHEncoderString)
    }
}