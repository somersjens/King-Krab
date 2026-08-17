// 
// GeneratedStringSymbols_InfoPlist.swift
// Auto-Generated symbols for localized strings defined in “InfoPlist.xcstrings”.
// 

import Foundation

#if SWIFT_PACKAGE
private nonisolated let resourceBundle = Foundation.Bundle.module
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.atURL(resourceBundle.bundleURL)
#else

private class ResourceBundleClass {}
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.forClass(ResourceBundleClass.self)
#endif

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
nonisolated extension LocalizedStringResource {
    /// Namespace for strings in file “InfoPlist.xcstrings”.
    enum InfoPlist {
        /**
         The app's name under its icon on the home screen. Follows the device language, not the in-app language switch, so it can differ from the language the game is being played in.
         
         Localized string for key “CFBundleDisplayName” in table “InfoPlist.xcstrings”.
         */
        static var cfbundleDisplayName: LocalizedStringResource {
            LocalizedStringResource("CFBundleDisplayName", table: "InfoPlist", bundle: resourceBundleDescription)
        }

        /**
         The short bundle name, used where the display name does not fit. Keep it under about 15 characters.
         
         Localized string for key “CFBundleName” in table “InfoPlist.xcstrings”.
         */
        static var cfbundleName: LocalizedStringResource {
            LocalizedStringResource("CFBundleName", table: "InfoPlist", bundle: resourceBundleDescription)
        }
    }
}