//
//  MuniStop.swift
//  Pods
//
//  Created by Adam Boyd on 2015-12-02.
//
//

import Foundation

private let tlStopIDEncoderString = "tlStopIDEncoder"

public class MuniStop: TransitStop {
    
    var tlStopID: String = ""
    
    //MARK: - NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Custom MuniStop properties
        tlStopID = aDecoder.decodeObjectForKey(tlStopIDEncoderString) as! String
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        //Custom MuniStop properties
        aCoder.encodeObject(tlStopID, forKey: tlStopIDEncoderString)
    }
}