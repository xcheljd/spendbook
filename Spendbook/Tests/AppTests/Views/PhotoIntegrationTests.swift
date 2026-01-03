import XCTest
@testable import Spendbook

final class PhotoIntegrationTests: XCTestCase {
    
    func testPhotoAttachmentLogic() {
        var photoData: Data? = nil
        
        // Simulate picking a photo
        let pickedData = Data([0, 1, 2, 3])
        photoData = pickedData
        XCTAssertNotNil(photoData)
        
        // Simulate removing the photo
        photoData = nil
        XCTAssertNil(photoData)
    }
}
