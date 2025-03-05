//
//  TableAction.swift
//  Andmix
//
//  Created by remy on 2018/3/22.
//

import UIKit

/// UITableView 的 delegate 代理对象
public final class TableAction: NSObject {
    
    public struct HeightCalculate: OptionSet {
        public let rawValue: UInt32
        public static let cell = HeightCalculate(rawValue: 1 << 0)
        public static let sectionHeader = HeightCalculate(rawValue: 1 << 1)
        public static let sectionFooter = HeightCalculate(rawValue: 1 << 2)
        public static let all: HeightCalculate = [.cell, .sectionHeader, .sectionFooter]
        public static let none: HeightCalculate = []
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }

    public typealias ActionClosure = (TableCellItem, IndexPath) -> Void
    public var isCellDeselect: Bool = true
    public var forwardDelegates = NSHashTable<UIScrollViewDelegate>.weakObjects()
    public var cellTapActions: [AnyHashable: ActionClosure] = [:]
    public var cellsTapActions: [AnyHashable: ActionClosure] = [:]
    public var cellDisplayActions: [AnyHashable: ActionClosure] = [:]
    public var cellsDisplayActions: [AnyHashable: ActionClosure] = [:]
    public var cellEndActions: [AnyHashable: ActionClosure] = [:]
    public var cellsEndActions: [AnyHashable: ActionClosure] = [:]
    /// 高度计算策略,禁止高度计算方法以提高性能(通过responds方法禁止,无论是否实现高度计算方法)
    public var heightCalculate: HeightCalculate = .all
    
    public func tap(cellItem: TableCellItem, action: @escaping ActionClosure) {
        cellTapActions[cellItem.hashValue] = action
    }
    
    public func tap(cellItemClass: TableCellItem.Type, action: @escaping ActionClosure) {
        cellsTapActions[cellItemClass.hash()] = action
    }
    
    public func display(cellItem: TableCellItem, action: @escaping ActionClosure) {
        cellDisplayActions[cellItem.hashValue] = action
    }
    
    public func display(cellItemClass: TableCellItem.Type, action: @escaping ActionClosure) {
        cellsDisplayActions[cellItemClass.hash()] = action
    }
    
    public func end(cellItem: TableCellItem, action: @escaping ActionClosure) {
        cellEndActions[cellItem.hashValue] = action
    }
    
    public func end(cellItemClass: TableCellItem.Type, action: @escaping ActionClosure) {
        cellsEndActions[cellItemClass.hash()] = action
    }
}

extension TableAction {
    
    private static let cellHeightSel: Selector = #selector(TableAction.tableView(_:heightForRowAt:))
    private static let sectionHeaderHeightSel: Selector = #selector(TableAction.tableView(_:heightForHeaderInSection:))
    private static let sectionFooterHeightSel: Selector = #selector(TableAction.tableView(_:heightForFooterInSection:))
    
    // 设置代理时会检查一遍代理对象实现的方法
    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            // TableAction实现的UITableViewDelegate代理方法
            switch aSelector {
            case TableAction.cellHeightSel:
                return heightCalculate.contains(.cell)
            case TableAction.sectionHeaderHeightSel:
                return heightCalculate.contains(.sectionHeader)
            case TableAction.sectionFooterHeightSel:
                return heightCalculate.contains(.sectionFooter)
            default:
                return true
            }
        } else if shouldForwardSelector(aSelector: aSelector) {
            // TableAction未实现的UITableViewDelegate代理方法,如果forwardDelegates中有对象实现该方法则返回true,触发消息转发流程
            for delegate in forwardDelegates.allObjects {
                if delegate.responds(to: aSelector) {
                    return true
                }
            }
        }
        return false
    }
    
    // 消息转发流程
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        for delegate in forwardDelegates.allObjects {
            if delegate.responds(to: aSelector) {
                return delegate
            }
        }
        return super.forwardingTarget(for: aSelector)
    }
}

extension TableAction {
    
    private func shouldForwardSelector(aSelector: Selector) -> Bool {
        let description = protocol_getMethodDescription(UITableViewDelegate.self, aSelector, false, true)
        return description.name != nil && description.types != nil
    }
    
    private func sectionView(with sectionClass: TableSection.Type, tableView: UITableView, sectionItem: TableSectionItem, suffix: String) -> UITableViewHeaderFooterView {
        let identifier = sectionClass.metaTypeName + suffix
        var section = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if section == nil {
            section = (sectionClass as UITableViewHeaderFooterView.Type).init(reuseIdentifier: identifier)
        }
        (section as! TableSection).updateBinding(sectionItem: sectionItem)
        return section!
    }
    
    private func action(_ cellItem: TableCellItem,
                        _ actions1: [AnyHashable: ActionClosure],
                        _ actions2: [AnyHashable: ActionClosure]) -> ActionClosure? {
        if let action = actions1[cellItem.hashValue] {
            return action
        } else if let action = actions2[type(of: cellItem).hash()] {
            return action
        }
        return nil
    }
}

extension TableAction: UITableViewDelegate {
    
    /**
     1.关闭高度估算(estimatedXXXHeight设为0):
        1-1.不实现高度计算方法,读rowHeight/sectionHeaderHeight/sectionFooterHeight
        1-2.实现高度计算方法(先全部cell调用计算总高度,每次显示cell时调用)
     2.开启高度估算(estimatedXXXHeight不为0):
        2-1.不实现高度计算方法,读rowHeight/sectionHeaderHeight/sectionFooterHeight(UITableView.automaticDimension时相对布局)
        2-2.实现高度计算方法(每次显示cell时调用,UITableView.automaticDimension时相对布局)
     */
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = (tableView.dataSource as? TableModel)?.cellItem(at: indexPath)?.cellHeight {
            return height
        }
        // cellHeight未实现则返回rowHeight
        return tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = (tableView.dataSource as? TableModel)?.sectionItem(at: section)?.headerHeight {
            return height
        }
        // headerHeight未实现则返回sectionHeaderHeight
        return tableView.sectionHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = (tableView.dataSource as? TableModel)?.sectionItem(at: section)?.footerHeight {
            return height
        }
        // footerHeight未实现则返回sectionFooterHeight
        return tableView.sectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let item = (tableView.dataSource as? TableModel)?.sectionItem(at: section), let cls = item.headerClass {
            item.index = section
            return sectionView(with: cls, tableView: tableView, sectionItem: item, suffix: item.headerReuseIDSuffix)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let item = (tableView.dataSource as? TableModel)?.sectionItem(at: section), let cls = item.footerClass {
            item.index = section
            return sectionView(with: cls, tableView: tableView, sectionItem: item, suffix: item.footerReuseIDSuffix)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let item = (tableView.dataSource as? TableModel)?.cellItem(at: indexPath) {
            item.cell?.selectionStyle = item.selectionStyle
            if let action = action(item, cellDisplayActions, cellsDisplayActions) {
                action(item, indexPath)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let item = (tableView.dataSource as? TableModel)?.cellItem(at: indexPath) {
            if let action = action(item, cellEndActions, cellsEndActions) {
                action(item, indexPath)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = (tableView.dataSource as? TableModel)?.cellItem(at: indexPath), let action = action(item, cellTapActions, cellsTapActions) {
            action(item, indexPath)
            if isCellDeselect { tableView.deselectRow(at: indexPath, animated: true) }
        }
    }
    
    @objc public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        forwardDelegates.allObjects.forEach { delegate in
            delegate.scrollViewDidScroll?(scrollView)
        }
    }
    
    @objc public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        forwardDelegates.allObjects.forEach { delegate in
            delegate.scrollViewWillBeginDragging?(scrollView)
        }
    }
    
    @objc public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        forwardDelegates.allObjects.forEach { delegate in
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
}
