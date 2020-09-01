import UIKit

// подготовка строки для использования в URL
extension String {
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}

