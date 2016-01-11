//
//  FirstViewController.swift
//  Mopidy-Commander
//
//  Created by Chih-Yung Liang on 2016/1/11.
//  Copyright © 2016年 Chih-Yung Liang. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController, AVAudioRecorderDelegate, NSURLSessionDataDelegate {

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet var actionBtns: [UIButton]!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var recorder: AVAudioRecorder!
    var fileURL: NSURL?
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordBtn.layer.cornerRadius = recordBtn.frame.width / 2
        for btn in actionBtns {
            btn.hidden = true
        }
        progressBar.hidden = true
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("tmpRecord.wav")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            try recorder = AVAudioRecorder(URL: self.fileURL!, settings: [
                AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
                AVSampleRateKey: NSNumber(int: 44100),
                AVLinearPCMBitDepthKey: NSNumber(int: 16),
                AVNumberOfChannelsKey: NSNumber(int: 1),
                AVLinearPCMIsBigEndianKey: NSNumber(bool: false),
                AVLinearPCMIsFloatKey: NSNumber(bool: false)
            ])
            recorder.delegate = self
        } catch {
            print("Error creating AVAudioRecorder")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func record() {
        let attr = NSMutableAttributedString(attributedString: recordBtn.attributedTitleForState(.Normal)!)
        
        if recorder.recording {
            attr.mutableString.setString("Record")
            recordBtn.setAttributedTitle(attr, forState: .Normal)
            recordBtn.backgroundColor = UIColor.grayColor()
            recordBtn.enabled = false
            recorder.stop()
        } else {
            attr.mutableString.setString("Recording")
            recordBtn.setAttributedTitle(attr, forState: .Normal)
            recordBtn.backgroundColor = UIColor(red: 0xAA, green: 0, blue: 0, alpha: 1)
            recorder.record()
        }
    }

    @IBAction func upload() {
        for btn in actionBtns {
            btn.enabled = false
        }
        progressBar.hidden = false
        progressBar.progress = 0
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://leon-iot.mybluemix.net/recognize")!)
        request.HTTPMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        request.HTTPBody = NSData(contentsOfURL: self.fileURL!)
        
        self.session.dataTaskWithRequest(request).resume()
    }
    
    @IBAction func reset() {
        for btn in actionBtns {
            btn.hidden = true
        }
        
        recordBtn.backgroundColor = UIColor.redColor()
        recordBtn.enabled = true
        progressBar.hidden = true
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Failed to record.")
            recordBtn.backgroundColor = UIColor.redColor()
            recordBtn.enabled = true
            return
        }
        
        for btn in actionBtns {
            btn.hidden = false
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print(error)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let alert = UIAlertController(title: "Upload Error!", message: error?.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        for btn in actionBtns {
            btn.enabled = true
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressBar.progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        let alert = UIAlertController(title: "Upload Successfully!", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
            for btn in self.actionBtns {
                btn.enabled = true
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

