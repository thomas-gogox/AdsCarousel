//
//  ViewController.swift
//  AdsCarouselDemo
//
//  Created by Thomas on 18/07/2023.
//

import UIKit
import AdsCarousel
import Combine

class ViewController: UIViewController {
    private var disposeBag = Set<AnyCancellable>()
    
    private enum Constants {
        static let margins: UIEdgeInsets = .init(top: 15, left: 12, bottom: 24, right: 12)
        static let adsMarginBottom: CGFloat = 20
        static let adsBannerRatio = 3.81
    }
    
    private lazy var adsPresenter: Ads = {
        let ads = Ads(aspectRatio: Constants.adsBannerRatio)
        ads.translatesAutoresizingMaskIntoConstraints = false
        return ads
    }()
    
    private lazy var adsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Hit me!!!", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(nextButton)
        view.addSubview(adsContainer)
        adsContainer.addSubview(adsPresenter)
        
        adsContainer.layer.cornerRadius = 8
        adsContainer.clipsToBounds = true
        
        setupProcessingChain()
        
        let contentView: UIView = view
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.margins.left),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.margins.right),
            nextButton.bottomAnchor.constraint(equalTo: adsContainer.topAnchor, constant: -Constants.adsMarginBottom),
            
            adsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.margins.left),
            adsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.margins.right),
            adsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.margins.bottom),
            adsContainer.widthAnchor.constraint(equalTo: adsContainer.heightAnchor, multiplier: Constants.adsBannerRatio),
            
            adsPresenter.topAnchor.constraint(equalTo: adsContainer.topAnchor),
            adsPresenter.rightAnchor.constraint(equalTo: adsContainer.rightAnchor),
            adsPresenter.bottomAnchor.constraint(equalTo: adsContainer.bottomAnchor),
            adsPresenter.leftAnchor.constraint(equalTo: adsContainer.leftAnchor),
        ])
        
        var items = [Item]()
        let target = URL(string: "https://gogox.com")!
        var url = URL(string: "https://i.gifer.com/Ezsm.gif")!
        items.append(Item.init(url: url, targetUrl: target))
        url = URL(string: "https://s3-ap-northeast-1.amazonaws.com/wp-gogovan.com/wp-content/uploads/sites/6/2022/06/23170716/dk-4.jpg")!
        items.append(Item.init(url: url, targetUrl: target))
        url = URL(string: "https://picsum.photos/id/237/4800/1200")!
        items.append(Item.init(url: url, targetUrl: target))
        url = URL(string: "https://picsum.photos/id/1/4800/1200")!
        items.append(Item.init(url: url, targetUrl: target))
        url = URL(string: "https://picsum.photos/id/2/4800/1200")!
        items.append(Item.init(url: url, targetUrl: target))
        adsPresenter.displayAds(items)
    }
    
    func setupProcessingChain() -> Void {
        adsPresenter.selectionPublisher
            .sink { indexPath in
                print("IndexPath: \(indexPath)")
            }
            .store(in: &disposeBag)
        
        adsPresenter.downloadStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allDownloaded in
                print("allDownloaded: \(allDownloaded)")
                self?.adsContainer.isHidden = !allDownloaded
            }
            .store(in: &disposeBag)
    }
}

