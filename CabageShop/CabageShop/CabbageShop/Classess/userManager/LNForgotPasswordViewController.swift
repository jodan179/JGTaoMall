//
//  LNForgotPasswordViewController.swift
//  TaoKeThird
//
//  Created by 付耀辉 on 2018/10/31.
//  Copyright © 2018年 付耀辉. All rights reserved.
//

import UIKit

class LNForgotPasswordViewController: LNBaseViewController {

    
    @IBOutlet weak var phone_number: UITextField!
    
    @IBOutlet weak var yanzheng_code: UITextField!
    
    @IBOutlet weak var new_password: UITextField!
    
    @IBOutlet weak var send_code: UIButton!
    
    @IBOutlet weak var show_paw: UIButton!
    
    @IBOutlet weak var certian: UIButton!
    
    @IBOutlet weak var top_space: NSLayoutConstraint!
    
    
    //声明定时器
    fileprivate var timer = Timer()
    
    fileprivate var timeNow = 59
    fileprivate var btnTitleStr = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "忘记密码"
        titleLabel.textColor = UIColor.white
        navigaView.backgroundColor = kSetRGBAColor(r: 0, g: 0, b: 0, a: 0)
        
        top_space.constant = 160+44

        certian.clipsToBounds = true
        certian.cornerRadius = certian.height/2
        certian.backgroundColor = kMainColor1()

    }

    @objc fileprivate func changeBtnTitle(){
        
        timeNow = timeNow-1
        
        if timeNow < 0 {
            send_code.isEnabled = true
            send_code.setTitle("发送验证码", for: .normal)
            invalidateTimer()
            timeNow = 60
        }else{
            send_code.isEnabled = false
            send_code.setTitle("\(timeNow)s后重新发送", for: .normal)
        }
    }
    
    //    定时器失效
    fileprivate func invalidateTimer() {
        timer.invalidate()
    }

    @IBAction func sendCode(_ sender: UIButton) {
        if phone_number.text?.count == 0 {
            setToast(str: "手机号不能为空")
            return
        }
        weak var weakSelf = self
        LQLoadingView().SVPwillShowAndHideNoText()
        
        let request = SKRequest.init()
        request.setParam(phone_number.text! as NSObject, forKey: "phone")
        
        request.callGET(withUrl: LNUrls().KSendSms) { (response) in
            
            LQLoadingView().SVPHide()
            if !(response?.success)! {
                return
            }
            
            weakSelf?.invalidateTimer()
            weakSelf?.timeNow = 60
            sender.isEnabled = false
            weakSelf?.btnTitleStr = String((weakSelf?.timeNow)!)+"s后重新发送"
            weakSelf?.send_code.setTitle(weakSelf?.btnTitle, for: .normal)
            weakSelf?.send_code.becomeFirstResponder()
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.changeBtnTitle), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: .commonModes)
            }
            
        }
    }

    
    @IBAction func showPaw(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        new_password.isSecureTextEntry = !sender.isSelected
    }
    
    
    @IBAction func certainAction(_ sender: UIButton) {
    
        if phone_number.text?.count == 0 {
            setToast(str: "请输入手机号")
            return
        }
        
        if yanzheng_code.text?.count == 0 {
            setToast(str: "请输入验证码")
            return
        }
        
        if new_password.text?.count == 0 {
            setToast(str: "请输入密码")
            return
        }

        weak var weakSelf = self
        LQLoadingView().SVPwillShowAndHideNoText()
        
        let request = SKRequest.init()
        request.setParam(phone_number.text! as NSObject, forKey: "phone")
        request.setParam(yanzheng_code.text! as NSObject, forKey: "code")
        request.setParam(new_password.text! as NSObject, forKey: "password")
        request.setParam(new_password.text! as NSObject, forKey: "password_confirmation")

        request.callPOST(withUrl: LNUrls().kReset_password) { (response) in
            
            LQLoadingView().SVPHide()
            if !(response?.success)! {
                setToast(str: "更改密码失败!")
                return
            }
            
            setToast(str: "更改密码成功!")
            weakSelf?.navigationController?.popViewController(animated: true)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        invalidateTimer()
    }

}
