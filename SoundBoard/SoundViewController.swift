//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Mac 03 on 5/19/21.
//  Copyright © 2021 Mac 03. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL: URL?
    var updateTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    func configurarGrabacion(){
        do{
            //creando session de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options:[])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //Creandodirección para el archivo de audio
            let basePath:String =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //Imprimir ruta donde
            print("*************")
            print(audioURL!)
            print("*************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject]=[:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabación de audio
            print("CREACION")
            grabarAudio = try AVAudioRecorder(url:audioURL!,settings:settings)
            grabarAudio!.prepareToRecord()
            
        }catch let error as NSError{
            
            print("ERROR",	error)
        }
    }
    func cambiar(timer: Timer){
        let minutes = Int(grabarAudio!.currentTime / 60)
        let seconds = Int(grabarAudio!.currentTime) - (minutes * 60)
        let timeInfo = String(format: "%d:%@%d", minutes, seconds < 10 ? "0" : "", seconds)
        labelTime.text = timeInfo
        print(timeInfo)
    }
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio!.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            updateTimer?.invalidate()
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: cambiar)
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
            let grabacion = Grabacion(context:context)
            grabacion.nombre = nombreTextField.text
            grabacion.audio = NSData(contentsOf: audioURL!)! as Data
            grabacion.duracion =            Double(audioPlayer.duration)
        }catch{}
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
