//
//  WPAlertManager.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/2.
//

import UIKit
import RxSwift

public class WPAlertManager {
    /// 弹窗队列
    private struct AlertQueue{
        let alert : WPAlertProtocol
        let level : Int
    }
    /// 弹窗视图
    private weak var currentAlert : WPAlertProtocol?
    /// 弹窗弹出的根视图
    private weak var targetView : UIView!{
        willSet{
            removeMask()
        }
    }
    /// 当前弹窗的mask
    private weak var maskView : WPAlertManagerMask?
    /// 弹窗队列
    private var alerts : [AlertQueue] = []{
        didSet{
            alerts.sort { elmt1, elmt2 in
                return elmt1.level < elmt2.level
            }
        }
    }
    /// 当前弹窗开始的frame
    private var currentAlertBeginFrame : CGRect = .zero
    /// 当前弹窗结束的frame
    private var currentAlertEndFrame : CGRect = .zero
    /// 当前弹窗的进度
    private var currentAlertProgress : Progress = .unknown
    
    /// 单例
    public static var  `default` : WPAlertManager = {
        let manager = WPAlertManager(target: UIApplication.shared.wp_topWindow)
        return manager
    }()
    
    public init(target:UIView){
       _ = self.target(in: target)
    }
    
    /// 添加一个弹窗
    public func addAlert(_ alert : WPAlertProtocol){
        alert.updateStatus(status: .cooling)
        alert.tag = WPAlertManager.identification()
        alerts.append(.init(alert: alert, level: Int(alert.alertLevel())))
    }
    
    /// 移除一个弹窗
    public func removeAlert(_ alert : WPAlertProtocol){
        
        currentAlert = nil
        alert.removeFromSuperview()
        
        let id = alert.tag
        let index = self.alerts.wp_index { elmt in
            return elmt.alert.tag == id
        }
        
        if let alertIndex = index {
            alerts.remove(at: Int(alertIndex))
        }
        alert.updateStatus(status: .remove)
        
        currentAlert = alerts.first?.alert
    }
    
    /// 添加一组弹窗会清除现有的弹窗
    /// - Parameter alerts: 弹窗
    public func setAlerts(_ alerts:[WPAlertProtocol])->WPAlertManager{
        self.alerts = []
        alerts.forEach {[weak self] elmt in
            self?.addAlert(elmt)
        }
        return self
    }
    
    /// 弹出一个弹窗 如果序列里有多个弹窗将会插入到下一个
    /// - Parameters:
    ///   - alert: 弹窗
    ///   - immediately: 是否延迟 true的话强制立马弹出 false的话会插入到下一个弹窗
    public func showNext(_ alert:WPAlertProtocol,immediately:Bool=false){
        alert.tag = WPAlertManager.identification()
        alerts.insert(.init(alert: alert, level: -1), at: 0)
        
        if currentAlertProgress == .didShow{
            alertAnimate(isShow: false,immediately: immediately)
        }else if currentAlertProgress == .unknown{
            alertAnimate(isShow: true,immediately: immediately)
        }else{
            alert.updateStatus(status: .cooling)
        }
    }
    
    /// 弹窗的根视图 在哪个视图上弹出
    /// - Parameter view:
    /// - Returns: 弹窗管理者
    public func target(in view:UIView) -> WPAlertManager {
        targetView = view
        return self
    }
    
    /// 隐藏当前的弹框 如果弹框序列里还有弹窗将会弹出下一个
    public func dismiss(){
        alertAnimate(isShow: false,immediately: false)
    }
    
    /// 显示弹窗
    public func show(){
        alertAnimate(isShow: true,immediately: false)
    }
}

extension WPAlertManager{
    
    /// 获取一个唯一标识
    private static func identification()->Int{
        return Int(arc4random_uniform(100) + arc4random_uniform(100) + arc4random_uniform(100))
    }
    
    /// 添加一个蒙版
    private func addMask(info:WPAlertManager.Mask){
        var resualt = false

        // 检查是否有蒙版
        targetView?.subviews.forEach({ elmt in
            if elmt.isKind(of: WPAlertManagerMask.self){
                resualt = true
            }
        })

        // 如果没有蒙版 那么添加一个
        if !resualt  {
            let maskView = WPAlertManagerMask(maskInfo: info, action: { [weak self] in
                self?.currentAlert?.touchMask()
            })
            self.maskView = maskView
            maskView.alpha = 0
            targetView?.insertSubview(maskView, at: 999)
            maskView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 删除蒙版
    private func removeMask(){
        maskView?.removeFromSuperview()
        maskView = nil
    }
    
    /// 判断是否还有下一个弹窗
    private func isNext()->Bool{
        let count = alerts.count
        return (count - 1) > 0
    }

    /// 执行弹窗动画
    /// immediately 是否强制
    private func alertAnimate(isShow:Bool,immediately:Bool){
        if let alert = currentAlert{
             
            if isShow {
                addMask(info: alert.maskInfo())
                if(alert.frame.size == .zero){ // 如果是layout布局那么强制刷新获取尺寸
                    alert.wp_x = -10000
                    alert.wp_y = -10000
                    UIApplication.shared.wp_topWindow.addSubview(alert)
                    alert.superview?.layoutIfNeeded()
                    alert.removeFromSuperview()
                }
                targetView?.insertSubview(alert, at: 1000)
                resetFrame(alert: alert)
                maskView?.maskInfo = alert.maskInfo()
                
                alert.updateStatus(status: .willShow)
                currentAlertProgress = .willShow
            }else{
                alert.updateStatus(status: .willPop)
                currentAlertProgress = .willPop
            }
            
            let duration = immediately ? 0 : (isShow ? alert.alertInfo().startDuration : alert.alertInfo().stopDuration)

            let animatesBolok : ()->Void = { [weak self] in
                guard let self = self else { return }
                
                alert.transform = CGAffineTransform.identity
                if isShow{
                    alert.frame = self.currentAlertBeginFrame
                    alert.alpha = 1
                    self.maskView?.alpha = 1
                }else{
                    alert.frame = self.currentAlertEndFrame
                    if !self.isNext() {
                        self.maskView?.alpha = 0
                    }
                    if alert.alertInfo().stopLocation == .center {
                        alert.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                    }
                }
            }
            
            let animateCompleteBlock : (Bool)->Void = {[weak self] resualt in
                guard let self = self else { return }
                
                if resualt{
                    if isShow {
                        alert.updateStatus(status: .didShow)
                        self.currentAlertProgress = .didShow
                    }else{
                        self.currentAlertProgress = .didPop
                        alert.updateStatus(status: .didPop)
                        self.removeAlert(alert)
                        
                        self.show()
                    }
                }
            }
            
            if alert.alertInfo().type == .default {
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    animatesBolok()
                }, completion: {resualt in
                    animateCompleteBlock(resualt)
                })
            }else if alert.alertInfo().type == .bounces{
                UIView.animate(withDuration: TimeInterval(duration), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
                    animatesBolok()
                }, completion: {resualt in
                    animateCompleteBlock(resualt)
                })
            }
        }else{
            currentAlert = alerts.first?.alert
            if  currentAlert != nil{
                show()
            }else{
                removeMask()
            }
        }
    }
    
    /// 计算弹窗的位置
    private func resetFrame(alert:WPAlertProtocol){
        
        let alertW : CGFloat = alert.wp_width
        let alertH : CGFloat = alert.wp_height
        let maxW : CGFloat = targetView?.wp_width ?? 0
        let maxH : CGFloat = targetView?.wp_height ?? 0
        let center : CGPoint = .init(x: (maxW - alertW) * 0.5, y: (maxH - alertH) * 0.5)
        
        var beginF : CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        var endF : CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        
        switch alert.alertInfo().startLocation {
        case .top(let offset):
            beginF.origin.x = center.x + offset.x
            beginF.origin.y = 0 + offset.y
            alert.wp_x = center.x + offset.x
            alert.wp_y = -alertH + offset.y
        case .left(let offset):
            beginF.origin.x = 0 + offset.x
            beginF.origin.y = center.y + offset.y
            alert.wp_x = -alertW + offset.x
            alert.wp_y = center.y + offset.y
        case .bottom(let offset):
            beginF.origin.x = center.x + offset.x
            beginF.origin.y = maxH-alertH + offset.y
            alert.wp_x = center.x + offset.x
            alert.wp_y = maxH + offset.y
        case .right(let offset):
            beginF.origin.x = maxW - alertW + offset.x
            beginF.origin.y = center.y + offset.y
            alert.wp_y = center.y + offset.y
            alert.wp_x = maxW + offset.x
        case .center(let offSet):
            beginF.origin.x = center.x + offSet.x
            beginF.origin.y = center.y + offSet.y
            alert.alpha = 0
            alert.frame.origin = center
            alert.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        }
        
        switch alert.alertInfo().stopLocation  {
        case .top:
            endF.origin.x = beginF.origin.x
            endF.origin.y = -alertH
        case .left:
            endF.origin.x = -alertW
            endF.origin.y = beginF.origin.y
        case .bottom:
            endF.origin.x = beginF.origin.x
            endF.origin.y = maxH
        case .right:
            endF.origin.x = maxW
            endF.origin.y = beginF.origin.y
        case .center:
            endF.origin = beginF.origin
        }
        
        currentAlertBeginFrame = beginF
        currentAlertEndFrame = endF
    }
    
}

public extension WPAlertManager{
    
    struct Alert {
        /// 动画类型
        let type : WPAlertManager.AnimateType
        /// 弹窗开始位置
        let startLocation : WPAlertManager.BeginLocation
        /// 弹窗弹出的时间
        let startDuration : TimeInterval
        /// 弹窗结束位置
        let stopLocation : WPAlertManager.EndLocation
        /// 弹窗结束的时间
        let stopDuration : TimeInterval
        
        
        /// 初始化一个弹窗信息
        /// - Parameters:
        ///   - type: 动画类型
        ///   - startLocation: 开始弹出的位置
        ///   - startDuration: 开始动画时间
        ///   - stopLocation: 结束弹出的位置
        ///   - stopDuration: 结束动画时间
        public init(type:WPAlertManager.AnimateType,
                    startLocation:WPAlertManager.BeginLocation,
                    startDuration:TimeInterval,
                    stopLocation:WPAlertManager.EndLocation,
                    stopDuration:TimeInterval){
            self.type = type
            self.startLocation = startLocation
            self.startDuration = startDuration
            self.stopLocation = stopLocation
            self.stopDuration = stopDuration
        }
    }

    struct Mask {
        /// 蒙板颜色
       public let color : UIColor
        /// 是否可以交互点击
       public let enabled : Bool
        /// 是否显示
       public let isHidden : Bool
        
        /// 初始化一个蒙版信息
        /// - Parameters:
        ///   - color: 蒙板颜色
        ///   - enabled: 是否可以交互点击
        ///   - isHidden: 是否隐藏
        public init(color:UIColor,enabled:Bool,isHidden:Bool) {
            self.color = color
            self.enabled = enabled
            self.isHidden = isHidden
        }
    }
    
    enum Progress{
        /// 挂起状态等待被弹出
        case cooling
        /// 将要显示
        case willShow
        /// 已经弹并显示
        case didShow
        /// 将要弹出
        case willPop
        /// 已经弹出完成
        case didPop
        /// 弹窗已经被移除
        case remove
        /// 未知状态
        case unknown
    }
    
    /// 动画类型
    enum AnimateType{
        /// 默认
        case `default`
        /// 弹簧效果
        case bounces
    }
    
    /// 弹窗开始位置
    enum BeginLocation {
        /// 顶部弹出
        case top(offset:CGPoint = .zero)
        /// 左边弹出
        case left(offset:CGPoint = .zero)
        /// 底部弹出
        case bottom(offset:CGPoint = .zero)
        /// 右边弹出
        case right(offset:CGPoint = .zero)
        /// 中间弹出
        case center(offset:CGPoint = .zero)
    }
    
    /// 弹出结束位置
    enum EndLocation {
        /// 顶部收回
        case top
        /// 左边收回
        case left
        /// 底部收回
        case bottom
        /// 右边收回
        case right
        /// 中心收回
        case center
    }
}

/// 蒙板视图
class WPAlertManagerMask: UIView {
    /// 垃圾桶
    let disposeBag = DisposeBag()

    /// 蒙板视图
    let contentView = UIButton()

    /// 蒙板info
    var maskInfo : WPAlertManager.Mask{
        didSet{
            contentView.backgroundColor = maskInfo.color
            contentView.isUserInteractionEnabled = !maskInfo.enabled
            isHidden = maskInfo.isHidden
        }
    }
    
    init(maskInfo:WPAlertManager.Mask,action:(()->Void)?) {
        self.maskInfo = maskInfo
        super.init(frame: .zero)
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.rx.tap.subscribe(onNext: { _ in
            action != nil ? action!() : print()
        }).disposed(by: disposeBag)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
