//
//  ViewController.swift
//  Task Project
//  Created by khushboo on 12/02/20.

import UIKit
import AVFoundation
import AVKit
import Toast_Swift

class ViewController: UIViewController {

    ////////////////////Variable Decleration////////////////////////////////////////////////
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var btnDownload: UIButton!
    
    var assetDownloadURLSession: AVAssetDownloadURLSession!
    var downloadTask: AVAssetDownloadTask!
    var downloadedURL: URL?

    ////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        /////////////createDownloadSession
        createDownloadSession()
    }

    ////////////////////////////////////////////////Functions////////////////////////////////////////////////
    func createDownloadSession() {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "HLSDownloadResuming")
        assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }

    func restoreDownloadTask() {
        let url = (downloadedURL != nil) ? downloadedURL! : URL(string: "https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8")!
        let urlAsset = AVURLAsset(url: url)
        downloadTask = assetDownloadURLSession.makeAssetDownloadTask(asset: urlAsset, assetTitle: "master", assetArtworkData: nil, options: nil)
    }

    func resume() {
        downloadTask.resume()
        btnDownload.setTitle("Pause", for: .normal)
    }

    func cancel() {
        downloadTask.cancel()
        btnDownload.setTitle("Resume", for: .normal)
    }
    
    //////////////////////////////////////////////////////////////UIButton Actions////////////////////////////////////////////////

    @IBAction func buttonDownload(_ sender: Any) {
        if downloadTask != nil, downloadTask.state == .running {
            cancel()
        } else {
            restoreDownloadTask()
            resume()
        }
    }
    
    @IBAction func onTapPlay(_ sender: Any) {

        let savedLink = UserDefaults.standard.string(forKey: "HLSPATH")
        
        if savedLink == nil{
            self.view.makeToast("Please download first!!")
        }else{
            let baseUrl = URL(fileURLWithPath: NSHomeDirectory())
            let assetUrl = baseUrl.appendingPathComponent(savedLink!)
            
            let avAssest = AVAsset(url: assetUrl)
            let playerItem = AVPlayerItem(asset: avAssest)
            let player = AVPlayer(playerItem: playerItem)

            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true, completion: {
                player.play()
            })
        }
        
    }
    
    
    @IBAction func onTapShowSubtitle(_ sender: Any) {
        
        let savedLink = UserDefaults.standard.string(forKey: "HLSPATH")
        if savedLink == nil{
            self.view.makeToast("Please download first!!")
        }else{
            let ShowListVC  = self.storyboard?.instantiateViewController(withIdentifier: "ShowListViewController") as! ShowListViewController
            ShowListVC.modalPresentationStyle = .overCurrentContext
            self.present(ShowListVC, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else {
            return // Download task is completed
        }
        // Download task is cancelled or something goes wrong, create new download task from current the partially downloaded file to resume
        btnDownload.setTitle("Resume", for: .normal)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        downloadedURL = location
        print(downloadedURL!)
        print(location.relativePath)
        btnDownload.setTitle("Downloaded", for: .normal)
        btnDownload.isUserInteractionEnabled = false
        UserDefaults.standard.set(location.relativePath, forKey: "HLSPATH")
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentageComplete = 0.0
        // Iterate over loaded time ranges
        for value in loadedTimeRanges {
            // Unpack CMTimeRange value
            let loadedTimeRange = value.timeRangeValue
            percentageComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        progressView.setProgress(Float(percentageComplete), animated: true)
    }
}


