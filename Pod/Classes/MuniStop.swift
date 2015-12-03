//
//  MuniStop.swift
//  Pods
//
//  Created by Adam Boyd on 2015-12-02.
//
//

import Foundation

private let tlStopIDEncoderString = "tlStopIDEncoder"
private let muniDirectionEncoderString = "muniDirectionEncoder"

public class MuniStop: TransitStop {
    
    //MARK: - Properties
    
    public var tlStopID: String = ""
    public var muniDirection: MuniRoute.MuniDirection = .Unknown
    
    //MARK: - NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Custom MuniStop properties
        tlStopID = aDecoder.decodeObjectForKey(tlStopIDEncoderString) as! String
        muniDirection = MuniRoute.MuniDirection(rawValue: aDecoder.decodeIntegerForKey(muniDirectionEncoderString))!
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        //Custom MuniStop properties
        aCoder.encodeObject(tlStopID, forKey: tlStopIDEncoderString)
        aCoder.encodeObject(muniDirection.rawValue, forKey: muniDirectionEncoderString)
    }
}