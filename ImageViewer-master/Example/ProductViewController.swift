//
//  ProductViewController.swift
//  Example
//
//  Created by Gaurang on 09/06/22.
//  Copyright © 2022 MailOnline. All rights reserved.
//

import UIKit
import Kingfisher


class ImageCollectionCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
     }()
    
    var url: URL? {
        didSet {
            imageView.kf.setImage(with: url)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProductViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let items: [String] = [
        "https://picsum.photos/id/127/4032/2272",
        "https://picsum.photos/id/118/1500/1000",
        "https://picsum.photos/id/119/3264/2176",
        "https://picsum.photos/id/12/2500/1667",
        "https://picsum.photos/id/120/4928/3264"
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: "image_cell")
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        collectionView.layoutIfNeeded()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = .zero
        flowLayout.itemSize = collectionView.bounds.size
    }
    
    private func showImageViewer(from displacedView: UIView, for index: Int) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: index, count: items.count)
        let galleryViewController = GalleryViewController(startIndex: index, itemsDataSource: self,
                                                          itemsDelegate: nil, displacedViewsDataSource: nil,
                                                          configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        let footerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        let footerView = ImageViewFooter(frame: footerFrame, currentIndex: 0, items: items, onItemSelected: { index in
            galleryViewController.page(toIndex: index)
        })
        galleryViewController.footerView = footerView
        galleryViewController.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
            headerView.count = self.items.count
            headerView.currentIndex = index
            footerView.selectItem(at: index, animated: true)
        }
        self.presentImageGallery(galleryViewController)
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        return [
            GalleryConfigurationItem.overlayColor(.clear),
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
            GalleryConfigurationItem.pagingMode(.carousel)
        ]
    }
}

extension ProductViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image_cell", for: indexPath) as! ImageCollectionCell
        cell.url = URL(string: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionCell {
            showImageViewer(from: cell.imageView, for: indexPath.row)
        }
    }
    
}


extension ProductViewController: GalleryItemsDataSource {

    func itemCount() -> Int {

        return items.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return .image { [unowned self] image in
            //$0(UIImage(named: "1")!)
            guard let url = URL(string: self.items[index]) else {
                image(UIImage())
                return
            }
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    image(value.image)
                case .failure(_):
                    image(UIImage())
                }
            }
        }
    }
}
