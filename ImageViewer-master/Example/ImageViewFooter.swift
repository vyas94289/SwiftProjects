//
//  ImageViewFooter.swift
//  Example
//
//  Created by Gaurang on 09/06/22.
//  Copyright © 2022 MailOnline. All rights reserved.
//

import UIKit

class ImageViewFooter: UIView {
    
    var items: [String]
    var currentIndex: Int
    var size: CGFloat = 40
    var spacing: CGFloat = 4
    var onItemSelected: ((_ index: Int) -> Void)?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ImageCollectionCell.self, forCellWithReuseIdentifier: "image_cell")
        cv.backgroundColor = .clear
        return cv
    }()
    
    init(frame: CGRect, currentIndex: Int, items: [String], onItemSelected: @escaping (_ index: Int) -> Void) {
        self.onItemSelected = onItemSelected
        self.currentIndex = currentIndex
        self.items = items
        super.init(frame: frame)
        configureCollectionView()
        configureSelectionView()
        updateIndicator()
    }
    
    lazy var selectionView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
    
    private func configureSelectionView() {
        addSubviews(selectionView)
        selectionView.layer.borderWidth = 3
        selectionView.layer.borderColor = UIColor.black.cgColor

    }
    
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: size, height: size)
        collectionView.contentInset = .init(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        collectionView.delegate = self
        collectionView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectItem(at: 0, animated: false)
        }

    }
    
    func selectItem(at index: Int, animated: Bool) {
        self.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCollectionCell {
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.selectionView.frame.origin.x = cell.frame.origin.x - self.spacing
                }
            } else {
                self.selectionView.frame.origin.x = cell.frame.origin.x - self.spacing
            }
        }
    }
    
    func updateIndicator() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ImageViewFooter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image_cell", for: indexPath) as! ImageCollectionCell
        cell.url = URL(string: items[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionCell {
            UIView.animate(withDuration: 0.3) {
                self.selectionView.frame.origin.x = cell.frame.origin.x - self.spacing
            }
            onItemSelected?(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = Int(size) * items.count
        let totalSpacingWidth = 4 * (items.count - 1)

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}
