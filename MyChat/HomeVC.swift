//
//  HomeVC.swift
//  MyChat
//
//  Created by abc on 2019/12/31.
//  Copyright © 2019 com.cn. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomChatVIew: UIView!
    // 消息模型数组
    var dataList = [ChatDataModel]()
    //消息文本输入框
    let inputTextView = UITextView()
    //w消息显示的最大宽度
    var textMaxW : CGFloat = 0.00
    //语音部件
    let leftBtn = UIButton.init(type: .custom)
    let icon = UIImage(named: "micIcon")
    let iconFill = UIImage(named: "micIconFill")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textMaxW = ScreenW - 80 - 60 - 10
        //1 初开始默认设置几条历史消息
        for _ in 0..<10 {
            let text = "Today is a good day"
            let chatDataModel = ChatDataModel()
            chatDataModel.text = text
            let size = self.getTextRectSize(text: text, fontSize: 14, size: CGSize.init(width: textMaxW, height: CGFloat.greatestFiniteMagnitude))
            chatDataModel.textH = size.height
            chatDataModel.textW = size.width
            self.dataList.append(chatDataModel)
        }
        //顶部标题
        self.title = "聊天窗口"
        //init tableView size
        tableView.frame = CGRect.init(x: 0, y: navStatusBarH, width: ScreenW, height: ScreenH - navStatusBarH - bottomSafeH - 50)
        // set background color to gray
        tableView.backgroundColor = GRAY_BACKGROUND_COLOR
        // set tableView delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        //tableView's footerview
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenW, height: 20))
        //delete separator between cells
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // register cell
        tableView.register(ChatCell.classForCoder(), forCellReuseIdentifier: "ChatCell")
        // set bottom chat view size
        bottomChatVIew.frame = CGRect.init(x: 0, y: ScreenH - bottomSafeH - 50, width: ScreenW, height: 50 + bottomSafeH)
        // set input text view size
        inputTextView.frame = CGRect.init(x: 60, y: 10, width: ScreenW - 120, height: 30)
        // set input text view color
        inputTextView.backgroundColor  = UIColor.white
        // set input text view delegate
        inputTextView.delegate = self
        // set input text view text color
        inputTextView.textColor = UIColor.black
        // set input text view corner radius
        inputTextView.layer.cornerRadius = 4
        // add input text view as a subview to bottomchatview
        bottomChatVIew.addSubview(inputTextView)
        // left button: voice
        
        leftBtn.frame = CGRect.init(x: 5, y: 5, width: 40, height: 40)
        // use characters for button
        //leftBtn.setTitle("Voice", for: .normal)
        //leftBtn.setTitleColor(.black, for: .normal)
        // use icons for button
        leftBtn.setBackgroundImage(icon, for: .normal)
        // 语音按钮添加点击事件 // set default to be false
        leftBtn.isEnabled = false  //2
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                print("something doesn't know")
            }
            
            OperationQueue.main.addOperation() {
                self.leftBtn.isEnabled = isButtonEnabled
            }
        }
        leftBtn.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        leftBtn.addTarget(self, action: #selector(buttonRelease), for: .touchUpInside)
        
        
        bottomChatVIew.addSubview(leftBtn)
        // send button on the right
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect.init(x: ScreenW - 55, y: 5, width: 50, height: 40)
        rightBtn.setTitle("Send", for: .normal)
        //发送按钮添加点击事件
        rightBtn.addTarget(self, action: #selector(clickRelease), for: .touchUpInside)
        rightBtn.setTitleColor(.black, for: .normal)
        bottomChatVIew.addSubview(rightBtn)
        
        //4
        //监控键盘的弹出
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardFrameCHange(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //监控键盘的隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //5进制自动内容下移
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    //MARK: ---------  键盘弹出时
    @objc func keyBoardFrameCHange(noti:Notification) {
        //
        
        // 获取键盘通知数据
        guard let userInfo = noti.userInfo! as? [String : AnyObject] else {
            return
        }
        
        let keyBoardInfo2 = userInfo["UIKeyboardFrameEndUserInfoKey"]
        //键盘的高度
        let endY = keyBoardInfo2!.cgRectValue.size.height
        //弹出需要用的时间
        let aTime = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as! TimeInterval
        UIView.animate(withDuration: aTime) { [weak self]() -> Void in
            //动画改编bottomChatVIew偏移和tableView的位置
            self?.bottomChatVIew.transform = CGAffineTransform(translationX: 0, y: -endY)
            self?.tableView.frame = CGRect.init(x: 0, y: navStatusBarH, width: ScreenW, height: ScreenH - navStatusBarH - bottomSafeH - 50 - endY)
        }
        // tableviewd滚动到底部最后t一条消息
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    //MARK: ---------  键盘隐藏时
    @objc func keyBoardWillHide(noti:Notification) {
        //
        
        // 获取键盘通知数据
        guard let userInfo = noti.userInfo! as? [String : AnyObject] else {
            return
        }
         //弹出需要用的时间
        let aTime = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as! TimeInterval
        //设置一个 aTime 时间内的动画
        UIView.animate(withDuration: aTime) { [weak self]() -> Void in
            //动画改编bottomChatVIew偏移和tableView的位置
            self?.bottomChatVIew.transform = CGAffineTransform.identity
            self?.tableView.frame = CGRect.init(x: 0, y: navStatusBarH, width: ScreenW, height: ScreenH - navStatusBarH - bottomSafeH - 50)
        }
        // tableviewd滚动到底部最后一条消息
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    //MARK: ---------  点击发送
    @objc func clickRelease()  {
        //内容为空 不能发送
        if self.inputTextView.text == ""{
            return
        }
        //获取文本
        let text = self.inputTextView.text!
        //创建这条消息的模型 包括文本  文本宽度 文本高度
        let chatDataModel = ChatDataModel()
        chatDataModel.text = text
        //根据固定宽度获取文本的大小,
        let size = self.getTextRectSize(text: text, fontSize: 14, size: CGSize.init(width: textMaxW, height: CGFloat.greatestFiniteMagnitude))
        chatDataModel.textH = size.height
        chatDataModel.textW = size.width
        //将消息模型添加到数组内
        self.dataList.append(chatDataModel)
        //刷新tableView
        tableView.reloadData()
        // tableviewd滚动到底部最后一条消息
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        //输入框内容清空
        self.inputTextView.text = ""
    }
    
}
@available(iOS 10.0, *)
extension HomeVC:UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIScrollViewDelegate, SFSpeechRecognizerDelegate{
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //允许键盘取消(隐藏)
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tableView 有多少行数据
        return self.dataList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //tableView的每行高度,  顶部底部各留20 加上文本高度
       let model = self.dataList[indexPath.row]
        return model.textH + 20 + 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //展示消息cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        //取消选中样式
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let model = self.dataList[indexPath.row]
        //消息背景的位置大小
        cell.bgView.frame = CGRect.init(x: ScreenW - 60 - model.textW - 10 , y: 10, width:model.textW + 20, height: model.textH + 20)
        //消息标题的位置大小
        cell.titleLab.frame = CGRect.init(x: ScreenW - 60 - model.textW , y: 20, width:model.textW, height: model.textH)
        //消息文本
        cell.titleLab.text = model.text
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating {
            //如果手在滑动消息tableView,q隐藏键盘
            self.inputTextView.resignFirstResponder()
        }
        
    }
    
    // 根据 文本   字体   指定宽度高度, 获取字体占用的位置大小
    func getTextRectSize(text:String?,fontSize:CGFloat,size:CGSize) -> (CGRect) {
        if text == nil || text == "" {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        let newText  = text! as NSString
        let font = UIFont.systemFont(ofSize: fontSize)
        
        let attributes = [NSAttributedString.Key.font : font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect  =  newText.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect
    }
    
    // voice recoginition code
    func startRecording() {
            
            if recognitionTask != nil {
                recognitionTask?.cancel()
                recognitionTask = nil
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true, options:.notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
    //        let inputNode = audioEngine.inputNode else {
    //            fatalError("Audio engine has no input node")
    //        }
            let inputNode = audioEngine.inputNode //skeptical about how to fix this
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
            recognitionRequest.shouldReportPartialResults = true
            
            // save the previous result
        let previousOutput = self.inputTextView.text
            
            recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                
                var isFinal = false
                
                if result != nil {
                    self.inputTextView.text = previousOutput! + (result?.bestTranscription.formattedString)!
                    isFinal = (result?.isFinal)!
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.leftBtn.isEnabled = true
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
            
        }
        
        func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
            if available {
                leftBtn.isEnabled = true
            } else {
                leftBtn.isEnabled = false
            }
        }
        
        
        
    @objc func buttonRelease(_ sender: AnyObject) {
             if audioEngine.isRunning {
                 audioEngine.stop()
                 recognitionRequest?.endAudio()
                 leftBtn.isEnabled = false
                 leftBtn.setBackgroundImage(icon, for: .normal)
             }
         }
         

    @objc func buttonDown(_ sender: Any) {
             startRecording()
             leftBtn.isEnabled = false
             leftBtn.setBackgroundImage(iconFill, for: .normal)
         }
}
