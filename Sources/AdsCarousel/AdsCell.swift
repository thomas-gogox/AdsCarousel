#if canImport(UIKit)

import UIKit

class AdsCell: UICollectionViewCell {
    
    static var reuseIdentifier: String = {
        "AdsCell"
    }()
    
    private lazy var adsImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        self.clipsToBounds = true
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        
        contentView.addSubview(adsImageView)
        NSLayoutConstraint.activate([
            adsImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            adsImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            adsImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            adsImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])
    }
    
    func configure(with image: UIImage?) {
        adsImageView.image = image
    }
}


#endif
