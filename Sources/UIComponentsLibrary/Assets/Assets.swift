import SwiftUI

public struct ColorAssetLibrary {
    public static let clear = Color.clear
    public static let disabled = Color("disabled", bundle: .module)
    public static let white = Color("white", bundle: .module)
    public static let black = Color("black", bundle: .module)
    public static let lightGrey = Color("light-grey", bundle: .module)
    public static let grey = Color("grey", bundle: .module)
    public static let darkGrey = Color("dark-grey", bundle: .module)
    public static let red = Color("red", bundle: .module)
    public static let blue = Color("lightBlue", bundle: .module)
}

public struct ImageAssetLibrary {
    public struct Common {
        public static let back = Image("back-button", bundle: .module)
        public static let error = Image("error-icon", bundle: .module)
		public static let add = Image("add-button", bundle: .module)
		public static let menu = Image("black-disclosure", bundle: .module)
    }
}
