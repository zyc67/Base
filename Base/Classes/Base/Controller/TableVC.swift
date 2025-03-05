//
//  TableVC.swift
//  Andmix
//
//  Created by remy on 2018/3/18.
//

import UIKit

open class TableVC: BaseVC, UITableViewDelegate {
    
    public var tableView: UITableView!
    public var tableModel: TableModel!
    public var tableAction: TableAction!
    
    open override func loadView() {
        super.loadView()
        tableView = UITableView(frame: contentFrame, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        // 默认关闭高度估算
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        // 默认高度自适应,相对布局
        tableView.rowHeight = UITableView.automaticDimension
        // 默认设为leastNonzeroMagnitude(系统有默认值)
        tableView.sectionHeaderHeight = .leastNonzeroMagnitude
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableModel = TableModel()
        tableAction = TableAction()
        tableAction.forwardDelegates.add(self)
        tableView.dataSource = tableModel
        tableView.delegate = tableAction
        view.addSubview(tableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 只在 delegate 为空时重新设置
        if tableView.delegate == nil {
            #if DEBUG
            ANPrint("Warning: TableView delegate was nil in viewWillAppear")
            #endif
            tableView.delegate = tableAction
        }
    }
}

public class TableManager {
    
    public let view: UITableView
    public let model: TableModel
    public let action: TableAction
    
    private init(_ view: UITableView,
                 _ model: TableModel,
                 _ action: TableAction) {
        self.view = view
        self.model = model
        self.action = action
    }
    
    public static func create(frame: CGRect,
                              style: UITableView.Style = .plain,
                              target: UIScrollViewDelegate? = nil,
                              closure: ((TableManager) -> Void)? = nil) -> TableManager {
        let tableView = UITableView(frame: frame, style: style)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        // 默认关闭高度估算
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        // 默认高度自适应,相对布局
        tableView.rowHeight = UITableView.automaticDimension
        // 默认设为leastNonzeroMagnitude(系统有默认值)
        tableView.sectionHeaderHeight = .leastNonzeroMagnitude
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        let tableModel = TableModel()
        let tableAction = TableAction()
        let manager = TableManager(tableView, tableModel, tableAction)
        if let target = target {
            tableAction.forwardDelegates.add(target)
        }
        closure?(manager)
        tableView.dataSource = tableModel
        tableView.delegate = tableAction
        return manager
    }
}
