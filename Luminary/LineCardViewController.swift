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
Hey hey, this is Jack from little lights! So you wanna come to my fun classroom? You know what! You need to show me your face.
Now, put your face in the frame.
Face accepted. Please say our magical words, 1，2，3...little lights, let’s go!
Wow! Leo. Are you ready? Let’s get started.
Oh, my! I can’t wait to start our class. Let’s watch a fun music video.
What a great song! Let‘s go through some words in that song.
Don’t forget to repeat after me.
Please read after me
Please try again!
You have done a Good job. In next section,
Don’t forget to point to the correct picture
Please listen to it carefully
Perfect! In next section,
please tell me what is on the screen
What is it?
The answer is
You have done a Great job. In next section,
Let’s practice how to use them.
Let’s listen to it, again!”
OK. Let’s practice.
Let’s take it into next level.
Cool. In next section,
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
