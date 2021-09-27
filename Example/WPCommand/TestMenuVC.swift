//
//  TestMenuVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/8/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import MJRefresh

class TestMenuVC: WPBaseVC, WPMenuViewDataSource {
    let tableVC = testTableVC()

    func menuHeaderViewForIndex(index: Int) -> WPMenuHeaderViewProtocol? {
//        if index == 2 || index == 4 {
//            return testHeader()
//        }else{
//            return nil
//        }
        return testHeader()
    }
    
    func menuBodyViewForIndex(index: Int) -> WPMenuBodyViewProtocol {
        if index == 0 {
            return testBodyView2()
        }else if index == 4{
            return tableVC
        }
        return testBodyView()
    }

    let menuView = WPMenuView(navigationHeight: 44)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        let items = [testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem()]
//
//        menuView.bounces = false
////        menuView.navigationInset = .init(left: 40, right: 30, spacing: 30)
//        menuView.setItems(items: items)
//        menuView.backgroundColor = .wp_random
        


        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .blue
        contentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(600)
        }
        
        let field = UITextField()
        view.addSubview(field)
        field.snp.makeConstraints { make  in
            make.centerY.equalToSuperview().offset(-200)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }
        field.backgroundColor = .wp_random

        // 测试代码
        let testView = UIView()
        testView.backgroundColor = .wp_random
        contentView.addSubview(testView)

        testView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
            make.bottom.equalToSuperview().offset(0)
        }
        
        WPSystem.share.keyboard.offsetY(in: testView).subscribe(onNext: { value in
            if testView.superview != nil {
                testView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(value)
                }
//                print(value)
            }
        })
        
        WPSystem.share.keyboard.willShow.subscribe(onNext: { value in
            print("键盘将要显示")
        })
        WPSystem.share.keyboard.didShow.subscribe(onNext: { value in
            print("键盘已显示")
        })
        WPSystem.share.keyboard.willHide.subscribe(onNext: { value in
            print("键盘将要隐藏")
        })
        WPSystem.share.keyboard.didHide.subscribe(onNext: { value in
            print("键盘已经隐藏")
        })
        WPSystem.share.keyboard.willChangeFrame.subscribe(onNext: { value in
            print("键盘将要改变高度")
        })
        WPSystem.share.keyboard.didChangeFrame.subscribe(onNext: { value in
            print("键盘已经改变高度")
        })
        
        
    }
    
    override func initSubView() {
        menuView.dataSource = self
        
        view.addSubview(menuView)
    }

    override func initSubViewLayout() {
        menuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

class testHeader: UILabel,WPMenuHeaderViewProtocol {
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {

    }
    
    func menuHeaderView() -> UIView? {
        return self
    }
    
    func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        return .autoLayout
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        numberOfLines = 4
        var mstr : String = ""
        for _ in 0..<20 + arc4random_uniform(60) {
            mstr += "测试代码"
        }

        text = mstr

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("释放代码")
    }
}

class testBodyView: UIView,WPMenuBodyViewProtocol {
    
    func menuBodyView() -> UIView? {
        return self
    }
    
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {
        switch status {
        case .normal:
            backgroundColor = .white
        default:
            backgroundColor = .blue
        }
    }
}

class testBodyView2: UIView,WPMenuBodyViewProtocol {
    
    func menuBodyView() -> UIView? {
        return self
    }
    
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {
        let view = UIImageView(image: UIColor.red.wp_image())

        menuView.navigationBackgroundView = view
        switch status {
        case .normal:
            backgroundColor = .white
        default:
            backgroundColor = .blue
        }
    }
}

class testMenuItem: UILabel,WPMenuNavigationViewProtocol {
    func menuItemWidth() -> CGFloat {
        return CGFloat(arc4random_uniform(50) + 50)
    }
    
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {
        text = "测试代码"
        if status == .normal {
            backgroundColor = .white
        }else{
            backgroundColor = .blue
        }
    }
}


class testTableVC: UITableView,WPMenuBodyViewProtocol,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero,style: style)
        delegate = self
        dataSource = self
        
        self.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            WPGCD.main_asyncAfter(.now() + 3, task: {[weak self] in
                self?.mj_header?.endRefreshing()
            })
        })
        
        self.panGestureRecognizer.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func menuBodyView() -> UIView? {
        return self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("点击了cell")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "4232")
        cell.textLabel?.text = "测试代码"
        return cell
    }
//
//    func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.
//    }
//
    
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {
        let view = UIView()
        view.backgroundColor = .clear
        menuView.navigationBackgroundView = nil
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
