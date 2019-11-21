import UIKit
import CustomPhotosFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PhotosNetworkManagerConfiguration.shared.accessKey = Constants.API.accessKey
        PhotosNetworkManagerConfiguration.shared.baseUrl = Constants.API.baseUrl
        return true
    }

}

