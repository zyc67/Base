//
//  TableCell.swift
//  Andmix
//
//  Created by remy on 2018/3/26.
//

import UIKit

open class TableCellItem: NSObject {
    
    public var model: Any?
    public var indexPath: IndexPath?
    public weak var cell: TableCell?
    public var selectionStyle: UITableViewCell.SelectionStyle = .none
    // 存储型属性适合构造函数中初始化,如果不走指定的构造函数需要通过实例对象赋值
    public var cellViewClass: TableCell.Type?
    // 计算型属性适合构造函数不确定的情况
    open var cellClass: TableCell.Type? {
        return cellViewClass
    }
    public var cellViewHeight: CGFloat?
    open var cellHeight: CGFloat? {
        return cellViewHeight
    }
    open var rowActions: [UITableViewRowAction]? {
        return nil
    }
    public var cellReuseIDSuffix: String = ""
    // 提高cell复用性能而将部分数据保存在item内时,该方法可供外部更新这些数据
    open func reload() {}
}

open class TableCell: UITableViewCell {
    
    public var cellItem: TableCellItem? {
        didSet {
            if let item = cellItem {
                item.cell = self
            }
            if let item = oldValue, item.cell == self {
                item.cell = nil
            }
        }
    }
    
    func updateBinding(cellItem: TableCellItem?) {
        self.cellItem = cellItem
        UIView.performWithoutAnimation {
            updateCell(cellItem: cellItem)
        }
    }
    
    open func updateCell(cellItem: TableCellItem?) {}
    
    open override func prepareForReuse() {
        self.cellItem = nil
        super.prepareForReuse()
    }
}
