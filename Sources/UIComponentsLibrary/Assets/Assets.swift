import SwiftUI

/// A library of predefined colors from the asset catalog.
public struct ColorAssetLibrary {
    /// A completely transparent color.
    public static let clear = Color.clear
    /// Color for disabled UI elements.
    public static let disabled = Color("disabled", bundle: .module)
    /// White color from the asset catalog.
    public static let white = Color("white", bundle: .module)
    /// Black color from the asset catalog.
    public static let black = Color("black", bundle: .module)
    /// Light grey color from the asset catalog.
    public static let lightGrey = Color("light-grey", bundle: .module)
    /// Grey color from the asset catalog.
    public static let grey = Color("grey", bundle: .module)
    /// Dark grey color from the asset catalog.
    public static let darkGrey = Color("dark-grey", bundle: .module)
    /// Red color from the asset catalog.
    public static let red = Color("red", bundle: .module)
    /// Light blue color from the asset catalog.
    public static let blue = Color("lightBlue", bundle: .module)
}

/// A library of predefined images from the asset catalog.
public struct ImageAssetLibrary {
    /// Common images used across the application.
    public struct Common {
        /// Back button icon.
        public static let back = Image("back-button", bundle: .module)
        /// Error icon.
        public static let error = Image("error-icon", bundle: .module)
		/// Add button icon.
		public static let add = Image("add-button", bundle: .module)
		/// Menu disclosure icon.
		public static let menu = Image("black-disclosure", bundle: .module)
    }
}
