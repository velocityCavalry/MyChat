//
//  HomeVC.swift
//  MyChat
//
//  Created by Xijie Lin on 1/6/20.
//  Copyright © 2020 com.cn. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomChatVIew: UIView!
    // array of chatDataModel, storing chat history
    var dataList = [ChatDataModel]()
    // input textView, for user to type message to send
    let inputTextView = UITextView()
    // the max width of the text
    var textMaxW : CGFloat = 0.00
    // speech to text recoginition parts
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
        //1 start with 10 default messages
        for _ in 0..<10 {
            let text = "Today is a good day"
            let chatDataModel = ChatDataModel()
            chatDataModel.text = text
            let size = self.getTextRectSize(text: text, fontSize: 14, size: CGSize.init(width: textMaxW, height: CGFloat.greatestFiniteMagnitude))
            chatDataModel.textH = size.height
            chatDataModel.textW = size.width
            self.dataList.append(chatDataModel)
        }
        // the title of window
        self.title = "MyChat"
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
        // set default to be false
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
        // adding listener for .touchDown and .touchUpInside event
        leftBtn.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        leftBtn.addTarget(self, action: #selector(buttonRelease), for: .touchUpInside)
        
        
        bottomChatVIew.addSubview(leftBtn)
        // send button on the right
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect.init(x: ScreenW - 55, y: 5, width: 50, height: 40)
        rightBtn.setTitle("Send", for: .normal)
        // adding .touchUpInside event listener to send button
        rightBtn.addTarget(self, action: #selector(clickRelease), for: .touchUpInside)
        rightBtn.setTitleColor(.black, for: .normal)
        bottomChatVIew.addSubview(rightBtn)
        
        //4
        // listening to when the keyboard shows
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardFrameCHange(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // listening to when the keyboard hides
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //5进制自动内容下移
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    //MARK: ---------  When keyboard shows up
    @objc func keyBoardFrameCHange(noti:Notification) {
        //
        
        // retrieving data of the keyboard
        guard let userInfo = noti.userInfo! as? [String : AnyObject] else {
            return
        }
        // identifies the ending frame rectangle of the keyboard in screen coordinates. The frame rectangle reflects the current orientation of the device.
        let keyBoardInfo2 = userInfo["UIKeyboardFrameEndUserInfoKey"]
        // the height of the keyboard
        let endY = keyBoardInfo2!.cgRectValue.size.height
        // the time it needs to pop up
        // The key for an NSNumber object containing a double that identifies the duration of the animation in seconds.
        let aTime = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as! TimeInterval
        UIView.animate(withDuration: aTime) { [weak self]() -> Void in
            //change bottomChatVIew and tableView positions
            self?.bottomChatVIew.transform = CGAffineTransform(translationX: 0, y: -endY)
            self?.tableView.frame = CGRect.init(x: 0, y: navStatusBarH, width: ScreenW, height: ScreenH - navStatusBarH - bottomSafeH - 50 - endY)
        }
        // tableview scroll to the last message
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    //MARK: ---------  when keyboard hides
    @objc func keyBoardWillHide(noti:Notification) {
        
        // retrieving data of the keyboard
        guard let userInfo = noti.userInfo! as? [String : AnyObject] else {
            return
        }
        
        // the time it needs for the keyboard to hide
        let aTime = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as! TimeInterval
        // animation with duration of aTime
        UIView.animate(withDuration: aTime) { [weak self]() -> Void in
             //change bottomChatVIew and tableView positions
            self?.bottomChatVIew.transform = CGAffineTransform.identity
            self?.tableView.frame = CGRect.init(x: 0, y: navStatusBarH, width: ScreenW, height: ScreenH - navStatusBarH - bottomSafeH - 50)
        }
        // tableview scroll to the last message
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    //MARK: ---------  sending content
    @objc func clickRelease()  {
        // if message body is emtpy, abort
        if self.inputTextView.text == ""{
            return
        }
        // retrieving the message body
        let text = self.inputTextView.text!
        // creating the ChatDataModel, including the width and height
        let chatDataModel = ChatDataModel()
        chatDataModel.text = text
        // getting the frame size according to the width and height
        let size = self.getTextRectSize(text: text, fontSize: 14, size: CGSize.init(width: textMaxW, height: CGFloat.greatestFiniteMagnitude))
        chatDataModel.textH = size.height
        chatDataModel.textW = size.width
        // adding the chatDataModel to datalist
        self.dataList.append(chatDataModel)
        // refresh tableView
        tableView.reloadData()
        // tableview scroll to the last message
        tableView.scrollToRow(at: IndexPath.init(row: self.dataList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        // reset inputTextView
        self.inputTextView.text = ""
    }
    
}
@available(iOS 10.0, *)
extension HomeVC:UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIScrollViewDelegate, SFSpeechRecognizerDelegate{
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        // keyboard hide
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // # of data in the tableView
        return self.dataList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // tableView's height + 20 overhead for top and botton + text height
       let model = self.dataList[indexPath.row]
        return model.textH + 20 + 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // show message cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        // cancel the selection style
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let model = self.dataList[indexPath.row]
        // adjust background for messages
        cell.bgView.frame = CGRect.init(x: ScreenW - 60 - model.textW - 10 , y: 10, width:model.textW + 20, height: model.textH + 20)
        // adjust title's size
        cell.titleLab.frame = CGRect.init(x: ScreenW - 60 - model.textW , y: 20, width:model.textW, height: model.textH)
        // message text
        cell.titleLab.text = model.text
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating {
            // if user is sliding the table view, hide input text view
            self.inputTextView.resignFirstResponder()
        }
        
    }
    
    // get text rectange size by the textview and font
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
