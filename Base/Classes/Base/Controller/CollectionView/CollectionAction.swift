//
//  CollectionAction.swift
//  Andmix
//
//  Created by remy on 2018/8/8.
//

import UIKit

/// UICollectionView 的 delegate 代理对象
public final class CollectionAction: NSObject {
    
    public typealias ActionClosure = (CollectionCellItem, IndexPath) -> Void
    public var isCellHighlight = false
    public var isCellDeselect = true
    public var forwardDelegates = NSHashTable<UIScrollViewDelegate>.weakObjects()
    public var cellTapActions: [AnyHashable: ActionClosure] = [:]
    public var cellsTapActions: [AnyHashable: ActionClosure] = [:]
    public var cellDisplayActions: [AnyHashable: ActionClosure] = [:]
    public var cellsDisplayActions: [AnyHashable: ActionClosure] = [:]
    public var cellEndActions: [AnyHashable: ActionClosure] = [:]
    public var cellsEndActions: [AnyHashable: ActionClosure] = [:]
    
    public func tap(cellItem: CollectionCellItem, action: @escaping ActionClosure) {
        cellTapActions[cellItem.hashValue] = action
    }
    
    public func tap(cellItemClass: CollectionCellItem.Type, action: @escaping ActionClosure) {
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

extension CollectionAction {
    
    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        } else if shouldForwardSelector(aSelector: aSelector) {
            // 接收UICollectionViewDelegate中未实现的代理方法,如果forwardDelegates中有对象实现该方法则返回true,触发消息转发流程
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

extension CollectionAction {
    
    private func shouldForwardSelector(aSelector: Selector) -> Bool {
        let description = protocol_getMethodDescription(UICollectionViewDelegate.self, aSelector, false, true)
        return description.name != nil && description.types != nil
    }
    
    private func action(_ cellItem: CollectionCellItem,
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

extension CollectionAction: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = (collectionView.dataSource as? CollectionModel)?.cellItem(at: indexPath)?.cellSize {
            return size
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let size = (collectionView.dataSource as? CollectionModel)?.sectionItem(at: section)?.sectionInset {
            return size
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let value = (collectionView.dataSource as? CollectionModel)?.sectionItem(at: section)?.sectionMinLineSpacing {
            return value
        }
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let value = (collectionView.dataSource as? CollectionModel)?.sectionItem(at: section)?.sectionMinItemSpacing {
            return value
        }
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let size = (collectionView.dataSource as? CollectionModel)?.sectionItem(at: section)?.headerSize {
            return size
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = (collectionView.dataSource as? CollectionModel)?.sectionItem(at: section)?.footerSize {
            return size
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = (collectionView.dataSource as? CollectionModel)?.cellItem(at: indexPath) {
            if let action = action(item, cellDisplayActions, cellsDisplayActions) {
                action(item, indexPath)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = (collectionView.dataSource as? CollectionModel)?.cellItem(at: indexPath) {
            if let action = action(item, cellEndActions, cellsEndActions) {
                action(item, indexPath)
            }
        }
    }
    
    // 不提供-collectionView:shouldHighlightItemAtIndexPath:,返回false会导致didSelectItemAt不触发
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = (collectionView.dataSource as? CollectionModel)?.cellItem(at: indexPath), let action = action(item, cellTapActions, cellsTapActions) {
            action(item, indexPath)
            if isCellDeselect { collectionView.deselectItem(at: indexPath, animated: true) }
        }
    }
}
