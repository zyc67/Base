//
//  CollectionCell.swift
//  Andmix
//
//  Created by remy on 2018/8/8.
//

import UIKit

open class CollectionCellItem: NSObject {
    
    public var model: Any?
    public var indexPath: IndexPath?
    public weak var cell: CollectionCell?
    public var cellViewClass: CollectionCell.Type?
    open var cellClass: CollectionCell.Type? {
        return cellViewClass
    }
    public var cellViewSize: CGSize = .zero
    open var cellSize: CGSize {
        return cellViewSize
    }
    public var cellReuseIDSuffix: String = ""
    open func reload() {}
}

open class CollectionCell: UICollectionViewCell {
    
    public var cellItem: CollectionCellItem? {
        didSet {
            if let item = cellItem {
                item.cell = self
            }
            if let item = oldValue, item.cell == self {
                item.cell = nil
            }
        }
    }
    
    func updateBinding(cellItem: CollectionCellItem?) {
        self.cellItem = cellItem
        UIView.performWithoutAnimation {
            updateCell(cellItem: cellItem)
        }
    }
    
    open func updateCell(cellItem: CollectionCellItem?) {}
    
    open override func prepareForReuse() {
        self.cellItem = nil
        super.prepareForReuse()
    }
}
