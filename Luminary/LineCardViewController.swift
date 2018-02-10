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
Ernesto de la Cruz: I have to sing, I have to play. The music, it’s not just in me, it is me.
Ernesto de la Cruz: When life gets me down, I play my guitar.
Ernesto de la Cruz: The rest of the world may follow the rules, but I must follow my heart.
Ernesto de la Cruz: You know that feeling, like there’s a song in the air and it’s playing just for you.
Ernesto de la Cruz: I hope you like it.
Ernesto de la Cruz: [singing] The feeling, so close, you can reach out and touch it.
Ernesto de la Cruz: I never knew I could want something so much, but it’s true.
Ernesto de la Cruz: Never underestimate the power of music.
Ernesto de la Cruz: No one was going to hand me my future, it was up to me to reach for my dream.
Ernesto de la Cruz: grab it tight and make it come true.
[as Miguel is secretly playing his guitar in the barn]
Miguel: Oh, it’s you. You’re going to get me into trouble, Dante.
Miguel: Someone could hear me! I wish someone wanted to hear me, other than you.
Miguel: I know, I’m not supposed to love music.
Miguel: But my great-grandma Coco’s father was the greatest musician of all time, Ernesto de la Cruz.
Miguel: One day he left with his guitar and never returned, now my family thinks music is a curse.
Miguel: Great-great-grandfather, none of them understand me. I’m supposed to play music!
Abuelita: No music! No music!
Abuelita: Miguel, eat your food. Here, have some more.
Miguel: No, gracias.
[everyone gasps in shock]
Miguel: I mean, si.
Abuelita: Now, that’s what I thought you said.
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
