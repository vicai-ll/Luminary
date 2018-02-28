//
//  UITableViewController.swift
//  Luminary
//
//  Created by Cai, Weiqi on 1/29/18.
//  Copyright © 2018 Cai, Weiqi. All rights reserved.
//

import UIKit

struct Line {
    let text: String
}

class LineCardViewController: UITableViewController {
    var lines = [Line]()
    var initIndex: Int?
    let identifier: String = "tableCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Transcripts"
        initializeTheLines()
    }
    
    func initializeTheLines() {
        let transcript = """
Hey hey, this is little lights! So you wanna come to my fun classroom? You know what! You need to show me your face. Now, put your face in the frame. Now, put your face in the frame.
Face accepted. Please say our magical words, little lights, let’s go!
Wow! XX. Are you ready? Let’s get started.
Oh, my! I can’t wait to start our class. Let’s watch a fun music video.
Music!!!
What a great song!  Let us go through some words in that song. Don’t forget to repeat after me.
Please read after me!
Please try again!
Good Job! Now, let’s try to point to the correct picture.
Which one is Cat? Please say “A, B or C
You are doing great! In the next section, please tell me what is on the screen.
What is it?
You got the hang of reading these words. Let us practice how to use them.
Mom: Do you like dogs, Tom?
Tom: Yes!
Let us listen again!
Let’s take it to the next level.
Let us try again!
"""
        
        transcript.enumerateLines { line, _ in
            self.lines.append(Line(text: line))
        }
        
    }
    
    // MARK: UITableView DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? TableCell
        cell.configurateTheCell(lines[indexPath.row])
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            lines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}
