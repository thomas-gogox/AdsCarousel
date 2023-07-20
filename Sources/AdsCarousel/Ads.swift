#if canImport(UIKit)

import UIKit
import SDWebImage
import Combine

public protocol AdsProtocol {
    func displayAds(_ items: [Item]) -> Void
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class Ads: UIView, AdsProtocol, UICollectionViewDelegate {
    private enum Constants {
        static let height = 86.0
        static let spacing = 0.0
        static let columns = 1
        static let itemsPerRow = 1.0
        static let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    private var animationDuration: TimeInterval
    
    private var timer: Timer?
    
    private var firstVisibleIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    private let selectionSubject = PassthroughSubject<IndexPath, Never>()
    
    private(set) var aspectRatio: Double
    
    private var items = [Item]()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.sectionInsetReference = .fromSafeArea
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(AdsCell.self, forCellWithReuseIdentifier: AdsCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    public init(aspectRatio: Double,
                animationDuration: TimeInterval = 3.0) {
        self.aspectRatio = aspectRatio
        self.animationDuration = animationDuration
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var selectionPublisher: AnyPublisher<IndexPath, Never> {
        selectionSubject.eraseToAnyPublisher()
    }
    
    private func setupViews() -> Void {
        self.backgroundColor = UIColor(white: 0.95, alpha: 0.95)
        self.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        timer = Timer.scheduledTimer(timeInterval: animationDuration, target: self, selector: #selector(moveToNextAds), userInfo: nil, repeats: true)
    }
    
    public func displayAds(_ items: [Item]) -> Void {
        self.items = items
        for item in items {
            SDWebImageDownloader.shared.downloadImage(with: item.url, options: [.progressiveLoad], progress: nil)
        }

        collectionView.reloadData()
    }
    
    @objc func moveToNextAds() {
        guard items.count > 0 else {
            return
        }
        
        
         let indexPath = firstVisibleIndexPath
            if (indexPath.row < items.count - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: indexPath.row + 1, section: indexPath.section)
//                print("Row: \(indexPath1!.row)")
                firstVisibleIndexPath = indexPath1!
                collectionView.isPagingEnabled = false
                collectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
                collectionView.isPagingEnabled = true
            }
            else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: indexPath.section)
//                print("Row1: \(indexPath1!.row)")
                firstVisibleIndexPath = indexPath1!
                collectionView.isPagingEnabled = false
                collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
                collectionView.isPagingEnabled = true
            }
    
    }
}

// MARK: - UICollectionViewDataSource
extension Ads: UICollectionViewDataSource {
    // 1
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    // 2
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    // 3
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AdsCell.reuseIdentifier,
            for: indexPath
        ) as! AdsCell
        let item = items[indexPath.row]
        cell.configure(with: item.url)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension Ads: UICollectionViewDelegateFlowLayout {
    
    // 1
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 2
        let paddingSpace = Constants.sectionInsets.left * (Constants.itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / Constants.itemsPerRow
        let heightPerItem = widthPerItem - layout.sectionInset.top - layout.sectionInset.bottom
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    // 3
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    // 4
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.sectionInsets.left
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        guard index < items.count else {
            return
        }
        
        selectionSubject.send(indexPath)
    }
    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
//                               forItemAt indexPath: IndexPath) {
//        let index = indexPath.item
//        if index < items.count,
//           let cell = cell as? AdsCell {
//            let item = items[index]
//            cell.configure(with: item.url)
//        }
//    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)
            firstVisibleIndexPath = indexPath ?? IndexPath(row: 0, section: 0)
            break
        }
    }
}

#endif
