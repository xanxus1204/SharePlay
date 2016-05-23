//
//  AudioConverter.swift
//  SharePlay
//
//  Created by 椛島優 on 2016/04/22.
//  Copyright © 2016年 椛島優. All rights reserved.
//

import Foundation
import MediaPlayer
class AudioExporter: NSObject {
    
    func convertItemtoAAC(item:MPMediaItem) -> NSURL {
        
        let url:NSURL = item.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        let urlAsset:AVURLAsset = AVURLAsset(URL: url)
        let exportSession:AVAssetExportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetAppleM4A)!
        exportSession.outputFileType = exportSession.supportedFileTypes[0]
        
        //Documentsフォルダに保存していく
        let docDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)[0]
        
        let itemTitleString:String = item.valueForProperty(MPMediaItemPropertyTitle) as! String
        
        let filePath:String = docDir + "/" + itemTitleString + ".m4a"
        
        let savePathforCAF:String = docDir + "/" + itemTitleString + ".caf"
        exportSession.outputURL = NSURL(fileURLWithPath: filePath)
        let fileManager:NSFileManager = NSFileManager()
        let saveUrlforCAF:NSURL = NSURL(fileURLWithPath: savePathforCAF)
        //ファイルの消去作業　べつの場所でやろう
//        fileManager.removeItemAtPath(filePath)
//        fileManager.removeItemAtPath(savePath)
        do{
            try fileManager.createDirectoryAtPath(docDir, withIntermediateDirectories: true, attributes: nil)
            
        }catch{
            print("Cannnot make a direc†ory")
        }
        let savePathforAAC:String = docDir + "/" + itemTitleString + ".aac"
        let saveUrlforAAC = NSURL(fileURLWithPath: savePathforAAC)
        
        //ここまで準備
        exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            print("Export Complete")
            
            let converter:AudioConverter = AudioConverter()
            
            let extConverter:ExtAudioConverter = ExtAudioConverter()
            
            
            converter.convertFrom(exportSession.outputURL, toURL: saveUrlforCAF)
            
            extConverter.convertFrom(saveUrlforCAF, toURL: saveUrlforAAC)

            
            
        })
        return saveUrlforAAC
        
        
        
    }
}