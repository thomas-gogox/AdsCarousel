#if canImport(UIKit)
import XCTest
import Combine
@testable import AdsCarousel

/// The carousel must show exactly one whole ad, also after its width changes
/// (rotation, fold / unfold, Split View).
final class AdsLayoutTests: XCTestCase {
    private let ratio = 3.81
    private var window: UIWindow!
    private var ads: Ads!
    private var host: UIView!

    override func setUpWithError() throws {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        host = UIView(frame: window.bounds)
        window.addSubview(host)
        window.isHidden = false

        ads = Ads(aspectRatio: ratio, animationDuration: 1000)
        ads.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(ads)
        NSLayoutConstraint.activate([
            ads.topAnchor.constraint(equalTo: host.topAnchor),
            ads.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            ads.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            ads.widthAnchor.constraint(equalTo: ads.heightAnchor, multiplier: ratio),
        ])

        let url = try Self.imageFile()
        let downloaded = expectation(description: "ads downloaded")
        let subscription = ads.downloadStatusPublisher.filter { $0 }.first().sink { _ in downloaded.fulfill() }
        ads.displayAds([Item(url: url, targetUrl: nil), Item(url: url, targetUrl: nil), Item(url: url, targetUrl: nil)])
        wait(for: [downloaded], timeout: 5)
        subscription.cancel()
        layout()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        ads = nil
        host = nil
    }

    private var carousel: UICollectionView {
        ads.subviews.compactMap { $0 as? UICollectionView }.first!
    }

    private func layout() {
        host.layoutIfNeeded()
        carousel.layoutIfNeeded()
    }

    private func resize(width: CGFloat) {
        host.frame.size.width = width
        layout()
    }

    private func visibleCellFrames() -> [CGRect] {
        carousel.visibleCells.map(\.frame).sorted { $0.minX < $1.minX }
    }

    func testEachAdFillsTheCarousel() {
        let first = carousel.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame

        XCTAssertEqual(first, CGRect(origin: .zero, size: carousel.bounds.size))
    }

    func testAdsTakeTheNewWidthWhenTheCarouselNarrows() {
        resize(width: 400)

        let first = carousel.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame
        XCTAssertEqual(first, CGRect(origin: .zero, size: carousel.bounds.size))
        XCTAssertEqual(carousel.bounds.width, 400, accuracy: 0.5)
    }

    func testAdsTakeTheNewWidthWhenTheCarouselWidens() {
        resize(width: 900)

        let first = carousel.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame
        XCTAssertEqual(first, CGRect(origin: .zero, size: carousel.bounds.size))
        XCTAssertEqual(carousel.contentSize.width, 3 * 900, accuracy: 0.5, "no part of the next ad shows")
    }

    func testTheCurrentAdStaysInViewAfterAWidthChange() {
        ads.moveToNextAds()
        carousel.setContentOffset(CGPoint(x: carousel.bounds.width, y: 0), animated: false) // end the animation

        resize(width: 400)

        XCTAssertEqual(carousel.contentOffset.x, 400, accuracy: 0.5, "still on the second ad, aligned to its page")
    }

    private static func imageFile() throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ad-\(UUID().uuidString).png")
        let image = UIGraphicsImageRenderer(size: CGSize(width: 381, height: 100)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 381, height: 100))
        }
        try XCTUnwrap(image.pngData()).write(to: url)
        return url
    }
}
#endif
