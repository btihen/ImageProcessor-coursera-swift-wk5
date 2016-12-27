//: ImageProcessor - a way to do simple image manipulation

// ** INITIALIZATION **
// there are 3 ways to create an imageProcessor file:
//
// 1) from an UIImage object
// let image = UIImage(named: "sample")
// var originalImage = ImageFilters(image: image!)
//
// 2) from a file name (of your choice)
//    becare with large photos - this is a slow program)
// var imageByName = ImageFilters(name: "sample")
//
// 3) by using the default built in image:
// var imageByName = ImageFilters()


// ** IMAGE MANIPULATION **
//
// AVAILABLE FILTERS
// 1) image lightening (helpful when under exposed)
//  a. lighten()     // assumes by 25%
//  b. lighten(0.3)  // any percentage you want
// 2) image darkening (helpful when over exposed)
//  a. darken()     // assumes by 25%
//  b. darken(0.3)  // any percentage you want
// 3) add contrast
//  a. moreContrast()     // assumes double
//  b. moreContrast(3)  // any factor you want
// 4) lessen contrast
//  a. lessContrast()     // assumes by half
//  b. lessContrast(0.3)  // any factor you want
// 5) making image greyscale -- this has no
//  a. greyScale()     // assumes by 25%
//  b. greyScale(0.3)  // any percentage you want


// ACCESS TO FILTERS
// 1) filter method -- to call desired behaviors individually - using default values
//    ImageFilters(name: "sample").filter( "moreContrast").filter("darken")
//
// 2) filter method -- call an arbitrary number of filters using default values
//    ImageFilters(name: "sample").filter(["moreContrast","darken",".greyScale","lessContrast","lighten"])
//
// 3) direct method call with or without preferred values - daisychained if multiple filters desired
//    ImageFilters(name: "sample").moreContrast(3.0).darken(0.3).greyScale().lessContrast(0.6).lighten(0.4)

// EXTRA -- access to image spec averages
//   ImageFilters(name: "sample").rgbaAverages()
//
// returns a dictionary of the average values in the image:
//   ["red": 118, "alpha": 255, "green": 98, "blue": 83]


import UIKit

let image = UIImage(named: "sample")

enum FilterTypes : String {
    case lighten
    case darken
    case lessContrast
    case moreContrast
    case greyScale
}

// Process the image!
class ImageFilters {
    var image: UIImage
    required init( image: UIImage ){
        self.image = image
    }
    convenience init(name: String) {
        self.init( image: UIImage(named: name)! )
    }
    convenience init() {
        self.init( image: UIImage(named: "sample")! )
    }
    
    func getfactor( percent: Double?) -> Double {
        var factor: Double
        if percent == nil {
            factor = 0.25
        } else if percent > 0 {
            if percent < 1.0 {
                factor = percent!
            } else {
                factor = percent! / 100.0
            }
        } else {
            factor = -1.0 * percent!
            if factor > 1.0 {
                factor = factor / 100.0
            }
        }
        return factor
    }
    
    func filter( filterName: String ) -> ImageFilters {
        switch filterName {
        case "darken":       self.darken()       // return darken()
        case "lighten":      self.lighten()      // return lighten()
        case "greyScale":    self.greyScale()    //return greyScale()
        case "moreContrast": self.moreContrast() //return moreContrast()
        case "lessContrast": self.lessContrast() //return lessContrast()
        default:             self.image
        }
        return ImageFilters( image: self.image )
    }
    
    func filter( filterNames: [String] ) -> ImageFilters {
        for i in 0..<filterNames.count {
            filter( filterNames[i] )
        }
        return ImageFilters( image: self.image )
    }
    
    // will need to calculate pixel averages often
    // func getAveragePixels( image: UIImage ) -> Array<Int> {
    // func getAveragePixels( image: UIImage ) -> Dictionary<String, Int> {
    func rgbaAverages( ) -> [String:Int] {
        var totalRed   = 0
        var totalGreen = 0
        var totalBlue  = 0
        var totalAlpha = 0
        var imageRGBA = RGBAImage(image: image)!
        let totalCount = imageRGBA.width * imageRGBA.height
        
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index   = y * imageRGBA.width + x
                var pixel   = imageRGBA.pixels[index]
                totalRed   += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue  += Int(pixel.blue)
                totalAlpha += Int(pixel.alpha)
            }
        }
        let avgRed   = totalRed   / totalCount
        let avgGreen = totalGreen / totalCount
        let avgBlue  = totalBlue  / totalCount
        let avgAlpha = totalAlpha / totalCount
        
        let averageValues: [String:Int] = [
            "red":   avgRed,
            "green": avgGreen,
            "blue":  avgBlue,
            "alpha": avgAlpha
        ]
        return averageValues
    }
    
    func lighten() -> ImageFilters {
        return lighten( 0.25 )
    }
    
    func lighten( percent: Double? ) -> ImageFilters {
        var imageRGBA = RGBAImage(image: image)!
        let factor: Double = getfactor( percent )
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index     = y * imageRGBA.width + x
                var pixel     = imageRGBA.pixels[index]
                let liteRed   = Double(pixel.red)   + (255 - Double(pixel.red  )) * factor
                let liteGreen = Double(pixel.green) + (255 - Double(pixel.green)) * factor
                let liteBlue  = Double(pixel.blue)  + (255 - Double(pixel.blue )) * factor
                pixel.red     = UInt8( max( 0, min(255, Int(liteRed)) ) )
                pixel.green   = UInt8( max( 0, min(255, Int(liteGreen)) ) )
                pixel.blue    = UInt8( max( 0, min(255, Int(liteBlue)) ) )
                imageRGBA.pixels[index] = pixel
            }
        }
        image = imageRGBA.toUIImage()!
        return ImageFilters( image: imageRGBA.toUIImage()! )
    }
    
    func darken() -> ImageFilters {
        return darken( 0.25 )
    }
    
    func darken( percent: Double? ) -> ImageFilters {
        var imageRGBA = RGBAImage(image: image)!
        let factor: Double = getfactor( percent )
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index     = y * imageRGBA.width + x
                var pixel     = imageRGBA.pixels[index]
                let darkRed   = Double(pixel.red)   * (1 - factor)
                let darkGreen = Double(pixel.green) * (1 - factor)
                let darkBlue  = Double(pixel.blue)  * (1 - factor)
                pixel.red     = UInt8( max( 0, min(255, Int(darkRed)) ) )
                pixel.green   = UInt8( max( 0, min(255, Int(darkGreen)) ) )
                pixel.blue    = UInt8( max( 0, min(255, Int(darkBlue)) ) )
                imageRGBA.pixels[index] = pixel
            }
        }
        image = imageRGBA.toUIImage()!
        return ImageFilters( image: imageRGBA.toUIImage()! )
    }
    
    func lessContrast() -> ImageFilters {
        return changeContrast( 0.5 )
    }
    
    func lessContrast( alpha: Double? ) -> ImageFilters {
        var factor: Double
        if alpha == nil {
            factor = 1.0
        } else if alpha == 0 {
            factor = 1.0
        } else if alpha > 1.0 {
            factor = 1.0 / alpha!
        } else {
            factor = alpha!
        }
        return changeContrast( factor )
    }
    
    func moreContrast() -> ImageFilters {
        return changeContrast( 2.0 )
    }
    
    func moreContrast( alpha: Double? ) -> ImageFilters {
        var factor: Double
        if alpha == nil {
            factor = 1.0
        } else if alpha == 0 {
            factor = 1.0
        } else if alpha > 1.0 {
            factor = alpha!
        } else {
            factor = 1.0 / alpha!
        }
        return changeContrast( factor )
    }
    
    func changeContrast( alpha: Double? ) -> ImageFilters {
        var imageRGBA = RGBAImage(image: image)!
        var factor: Double
        if alpha == nil {
            factor = 2.0
        } else if alpha >= 0.0 {
            factor = alpha!
        } else {
            factor = -1 * alpha!
        }
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index     = y * imageRGBA.width + x
                var pixel     = imageRGBA.pixels[index]
                let diffRed   = factor * ( Double(pixel.red)   - 128) + 128
                let diffGreen = factor * ( Double(pixel.green) - 128) + 128
                let diffBlue  = factor * ( Double(pixel.blue)   - 128) + 128
                pixel.red     = UInt8( max( 0, min(255, Int(diffRed)) ) )
                pixel.green   = UInt8( max( 0, min(255, Int(diffGreen)) ) )
                pixel.blue    = UInt8( max( 0, min(255, Int(diffBlue)) ) )
                imageRGBA.pixels[index] = pixel
            }
        }
        image = imageRGBA.toUIImage()!
        return ImageFilters( image: imageRGBA.toUIImage()! )
    }
    
    func greyScale() -> ImageFilters {
        var imageRGBA = RGBAImage(image: image)!
        for y in 0..<imageRGBA.height {
            for x in 0..<imageRGBA.width {
                let index     = y * imageRGBA.width + x
                var pixel     = imageRGBA.pixels[index]
                let totBright = Double(pixel.red) + Double(pixel.green) + Double(pixel.blue)
                let avgBright = totBright / 3.0
                pixel.red     = UInt8( max( 0, min(255, Int(avgBright)) ) )
                pixel.green   = UInt8( max( 0, min(255, Int(avgBright)) ) )
                pixel.blue    = UInt8( max( 0, min(255, Int(avgBright)) ) )
                imageRGBA.pixels[index] = pixel
            }
        }
        image = imageRGBA.toUIImage()!
        return ImageFilters( image: imageRGBA.toUIImage()! )
        
    }
    
}


// example initialization
var originalImage = ImageFilters(image: image!)
originalImage.rgbaAverages()


// example image manipulation by chaining filter call
var imageByFilterCall = ImageFilters(image: image!).filter( "moreContrast").filter( ["darken", "greyScale","lessContrast","lighten"])
imageByFilterCall.rgbaAverages()


// example image manipulation by chaining method calls
var imageByMethodCall = ImageFilters(name: "sample").moreContrast(3.0).darken(0.3).greyScale().lessContrast(0.6).lighten(0.4)
imageByMethodCall.rgbaAverages()
