//
//  ViewController.swift
//  HW_WarGame
//
//  Created by 曹家瑋 on 2023/6/3.
//

/*遊戲參與者：適用於2人遊戲。
 
 目標：將所有的牌都拿在手上。

 遊戲開始前，將一副撲克牌（不包含鬼牌，共52張）均等分給兩名玩家，每人各有26張。每人的牌堆面朝下，不能看自己的牌。

 接著，兩名玩家同時從自己的牌堆最上方抽出一張牌，並將之翻面。玩家將牌面朝上放在桌上，比較牌的數值。
 較大的牌贏得這一輪，並將這兩張牌收入自己的牌堆底部。在撲克牌中，2為最小，A為最大。

 如果兩人出的牌點數相同，則發生"戰爭"。每個玩家從自己的牌堆中再額外抽出三張牌，面朝下放在桌上，然後再各自抽一張牌，面朝上放在這三張牌上面。
 比較這兩張面朝上的牌，點數大的玩家會獲得所有桌上的牌。如果點數仍然相同，則重複"戰爭"的步驟，直到有一方贏得所有的牌。

 遊戲會繼續進行，直到一名玩家獲得所有的牌，此時該玩家為贏家。

 這個遊戲主要考驗的是運氣，因為玩家不能選擇他們要出的牌，並且不能看自己還剩下哪些牌。*/



// 新版（6/7）
import UIKit
import AVFoundation

class ViewController: UIViewController {

    // 戰爭狀態時玩家、電腦的卡牌，有4個outlet
    @IBOutlet var playerWarCardImageViews: [UIImageView]!
    @IBOutlet var computerWarCardImageViews: [UIImageView]!
    // 各自贏得的撲克牌
    @IBOutlet weak var playerWonCardImageView: UIImageView!
    @IBOutlet weak var computerWonCardImageView: UIImageView!
    // 玩家出的牌、電腦出的牌
    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var computerCardImageView: UIImageView!
    // 出牌 UIButton 的 Outlet
    @IBOutlet weak var playCardButton: UIButton!
    // 狀態提示文字
    @IBOutlet weak var hintLabel: UILabel!
    // 顯示當前贏得的牌數
    @IBOutlet weak var playerWonCardAmount: UILabel!
    @IBOutlet weak var computerWonCardAmount: UILabel!
    // 顯示當前手上的牌數
    @IBOutlet weak var playerHandCardAmount: UILabel!
    @IBOutlet weak var computerHandCardAmount: UILabel!
    // 顯示戰爭的第四張牌
    @IBOutlet weak var playerWarLastCardImageView: UIImageView!
    @IBOutlet weak var computerWarLastCardImageView: UIImageView!
    

    // 玩家的牌
    var playerDeck = [Card]()
    // 電腦的牌
    var computerDeck = [Card]()
    // 完整的牌組
    var fullDeck = [Card]()
    // 存放玩家、電腦贏得的牌
    var playerWonDeck = [Card]()
    var computerWonDeck = [Card]()

    // 音效播放
    let soundPlayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 建立完整的牌
        createFullDeck()

        // 洗牌並將牌平分給玩家以及電腦
        shuffleDeck(deck: &fullDeck)
        playerDeck = Array(fullDeck[0..<26])
        computerDeck = Array(fullDeck[26..<52])

        // 初始化狀態提示文字與目前的牌數（贏得的牌、手上的牌）
        hintLabel.text = "請出牌！"
        playerWonCardAmount.text = "\(playerWonDeck.count)"
        computerWonCardAmount.text = "\(computerWonDeck.count)"
        playerHandCardAmount.text = "\(playerDeck.count)"
        computerHandCardAmount.text = "\(computerDeck.count)"
    }

    // 點擊後出牌
    @IBAction func playCard(_ sender: UIButton) {
        // 出牌的音效
        playAudio(named: "CardDrop", fileType: "mp3")
        // 玩家與電腦都有牌時
        if !playerDeck.isEmpty && !computerDeck.isEmpty {

            // 取出各自撲克牌的第一張牌
            let playerCard = playerDeck.removeFirst()
            let computerCard = computerDeck.removeFirst()

            // 將取出的撲克牌顯示在 UIImageView 上
            let playerImageName = "\(playerCard.suit)_\(playerCard.rank)"
            let computerImageName = "\(computerCard.suit)_\(computerCard.rank)"
            playerCardImageView.image = UIImage(named: playerImageName)
            computerCardImageView.image = UIImage(named: computerImageName)

            // 如果牌是 A，則將其數值設為最大的數字
            var playerRank = playerCard.rank == 1 ? 14 : playerCard.rank
            var computerRank = computerCard.rank == 1 ? 14 : computerCard.rank

            // 比較玩家與電腦的牌數字的大小，並決定誰贏
            // 玩家贏
            if playerRank > computerRank {
                // 玩家贏得電腦的牌，將這兩張牌加到 「玩家贏得的牌」
                playerWonDeck.append(contentsOf: [playerCard, computerCard])

                // 顯示贏得的牌
                let playerWonImageName = "\(playerCard.suit)_\(playerCard.rank)"
                playerWonCardImageView.image = UIImage(named: playerWonImageName)

                // 顯示玩家贏得的牌的數量
                playerWonCardAmount.text = "\(playerWonDeck.count)"

                // 顯示手上的牌的數量
                playerHandCardAmount.text = "\(playerDeck.count)"
                computerHandCardAmount.text = "\(computerDeck.count)"

                // 提示文字
                hintLabel.text = "玩家數字比較大！玩家拿牌！"

                print("玩家贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
                print("玩家贏,玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )

            }
            // 電腦贏
            else if playerRank < computerRank {
                // 電腦贏得玩家的牌，將這兩張牌加到 「電腦贏得的牌」
                computerWonDeck.append(contentsOf: [playerCard, computerCard])

                // 顯示贏得的牌
                let computerWonImageName = "\(computerCard.suit)_\(computerCard.rank)"
                computerWonCardImageView.image = UIImage(named: computerWonImageName)

                // 顯示電腦贏得的牌的數量
                computerWonCardAmount.text = "\(computerWonDeck.count)"

                // 顯示手上的牌的數量
                playerHandCardAmount.text = "\(playerDeck.count)"
                computerHandCardAmount.text = "\(computerDeck.count)"

                // 提示文字
                hintLabel.text = "電腦數字比較大！電腦拿牌！"

                print("電腦贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
                print("電腦贏, 玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )
            }


            // 如果玩家的手牌已經空了
            if playerDeck.isEmpty {
                // 檢查玩家贏得的牌是否用完
                if playerWonDeck.isEmpty {
                    // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
                    playCardButton.isEnabled = false
                    hintLabel.text = "玩家牌不夠！電腦贏了！"
                    print("遊戲結束, 電腦贏")
                    return
                }
                // 如果玩家贏得的牌庫裡還有牌
                else {
                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
                    playerWonDeck.shuffle()
                    playerDeck.append(contentsOf: playerWonDeck)
                    playerWonDeck.removeAll()

                    // 顯示手上的牌的數量、並且清空玩家贏得的牌庫imageView
                    playerWonCardAmount.text = "\(playerWonDeck.count)"
                    computerWonCardAmount.text = "\(computerWonDeck.count)"
                    playerHandCardAmount.text = "\(playerDeck.count)"
                    computerHandCardAmount.text = "\(computerDeck.count)"
                    playerWonCardImageView.image = nil
                }
            }

            // 如果電腦的手牌已經空了
            if computerDeck.isEmpty {
                // 檢查電腦贏得的牌是否用完
                if computerWonDeck.isEmpty {
                    // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
                    playCardButton.isEnabled = false
                    hintLabel.text = "電腦牌不夠！玩家贏了！"
                    print("遊戲結束, 玩家贏")
                    return
                }
                // 如果電腦贏得的牌庫裡還有牌
                else {
                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
                    computerWonDeck.shuffle()
                    computerDeck.append(contentsOf: computerWonDeck)
                    computerWonDeck.removeAll()

                    // 顯示手上的牌的數量、並且清空電腦贏得的牌庫imageView
                    playerWonCardAmount.text = "\(playerWonDeck.count)"
                    computerWonCardAmount.text = "\(computerWonDeck.count)"
                    playerHandCardAmount.text = "\(playerDeck.count)"
                    computerHandCardAmount.text = "\(computerDeck.count)"
                    computerWonCardImageView.image = nil
                }
            }


            // 處理戰爭的情況，戰爭是否發生和局
            var warDraw = false
            // 計算戰爭和局贏家可拿的牌
            var warCardWinnerCount: Int = 0
            // 紀錄戰爭和局的次數
            var drawCount: Int = 0
            // 儲存戰爭期間的牌
            var temporaryWarDeck: [Card] = []
            // 空的撲克牌陣列來儲存戰爭中使用的卡牌
            var warCards: [Card] = []
            // 儲存導致戰爭狀態的兩張牌
            var originalCards: [Card] = []

            // 當雙方大小相同時，進入戰爭狀態
            while playerRank == computerRank {

                print("由於玩家\(playerRank), 電腦\(computerRank)一樣，因此進入戰爭狀態")     // 檢查導致戰爭的兩張牌的數字

                // 如果戰爭和局，清空戰爭卡牌陣列，準備處理新一輪的戰爭，避免重複添加。
                warCards.removeAll()
                // 如果戰爭和局，清空導致戰爭狀態的兩張牌，避免重複添加。
                originalCards.removeAll()

                // 導致戰爭的兩張牌
                originalCards.append(playerCard)
                originalCards.append(computerCard)
                print("儲存導致戰爭的牌\(originalCards)")                                   // 檢查導致戰爭的兩張牌是否有被正常添加
                

                // 檢查玩家是否有足夠的牌（發動戰爭需要 4 張牌） （測試）
                if playerDeck.count < 4 {

                    // 如果玩家沒有足夠的牌來進行戰爭，檢查贏得的牌堆是否有足夠的牌
                    if playerWonDeck.count < 4 {

                        // 如果玩家的牌和贏得的牌都不夠，那麼遊戲結束
                        playCardButton.isEnabled = false
                        hintLabel.text = "玩家的牌不夠進行戰爭！玩家輸了！"
                        print("遊戲結束，玩家輸了")
                        return
                    }
                    // 如果贏得的牌堆有足夠的牌，將贏得的牌堆洗牌，然後放入手牌中
                    else {
                        shuffleDeck(deck: &playerWonDeck)
                        playerDeck.append(contentsOf: playerWonDeck)
                        playerWonDeck.removeAll()

                        // 顯示手上的牌的數量
                        playerWonCardAmount.text = "\(playerWonDeck.count)"
                        computerWonCardAmount.text = "\(computerWonDeck.count)"
                        playerHandCardAmount.text = "\(playerDeck.count)"
                        computerHandCardAmount.text = "\(computerDeck.count)"
                        playerWonCardImageView.image = nil
                        print("戰爭狀態玩家當前牌太少，因此加入贏得的牌")
                    }
                }


                // 檢查電腦是否有足夠的牌（發動戰爭需要 4 張牌）（測試）
                 if computerDeck.count < 4 {

                    // 如果電腦沒有足夠的牌來進行戰爭，檢查贏得的牌堆是否有足夠的牌
                    if computerWonDeck.count < 4 {

                        // 如果電腦的牌和贏得的牌都不夠，那麼遊戲結束
                        playCardButton.isEnabled = false
                        hintLabel.text = "電腦的牌不夠進行戰爭！電腦輸了！"
                        print("遊戲結束，電腦輸了")
                        return
                    }
                    // 如果贏得的牌堆有足夠的牌，將贏得的牌堆洗牌，然後放入手牌中。
                    else {
                        shuffleDeck(deck: &computerWonDeck)
                        computerDeck.append(contentsOf: computerWonDeck)
                        computerWonDeck.removeAll()

                        // 顯示手上的牌的數量
                        playerWonCardAmount.text = "\(playerWonDeck.count)"
                        computerWonCardAmount.text = "\(computerWonDeck.count)"
                        playerHandCardAmount.text = "\(playerDeck.count)"
                        computerHandCardAmount.text = "\(computerDeck.count)"
                        computerWonCardImageView.image = nil
                        print("戰爭狀態電腦當前牌太少，因此加入贏得的牌")
                    }
                }
                

                // 移除雙方的前三張牌進入 "戰爭"。
                let playerWarCards = Array(playerDeck.prefix(3))
                playerDeck.removeFirst(3)
                let computerWarCards = Array(computerDeck.prefix(3))
                computerDeck.removeFirst(3)

                // 雙方前三張牌顯示卡背。
                for i in 0...2 {
                    playerWarCardImageViews[i].image = UIImage(named: "card_back")
                    playerWarCardImageViews[i].isHidden = false
                    computerWarCardImageViews[i].image = UIImage(named: "card_back")
                    computerWarCardImageViews[i].isHidden = false
                }
                
                // 將這些卡牌也添加到戰爭卡牌陣列中
                warCards.append(contentsOf: playerWarCards)
                warCards.append(contentsOf: computerWarCards)
                
                // 比較雙方第四張牌
                let playerWarLastCard = playerDeck.removeFirst()
                let computerWarLastCard = computerDeck.removeFirst()
                
                // 將取出的第四張牌顯示在UIImageView上
                let playerWarLastCardImageName = "\(playerWarLastCard.suit)_\(playerWarLastCard.rank)"
                let computerWarLastCardImageName = "\(computerWarLastCard.suit)_\(computerWarLastCard.rank)"
                playerWarLastCardImageView.image = UIImage(named: playerWarLastCardImageName)
                computerWarLastCardImageView.image = UIImage(named: computerWarLastCardImageName)
                playerWarLastCardImageView.isHidden = false
                computerWarLastCardImageView.isHidden = false
                
                
                // 將最後一張牌加入 warCards
                warCards.append(playerWarLastCard)
                warCards.append(computerWarLastCard)
                print(warCards)
                
                // 將A的數字調整為14最大
                playerRank = playerWarLastCard.rank == 1 ? 14 : playerWarLastCard.rank
                computerRank = computerWarLastCard.rank == 1 ? 14 : computerWarLastCard.rank
                print("戰爭狀態：玩家的最後一張\(playerWarLastCard.rank), 電腦的最後一張\(computerWarLastCard.rank)")   // 檢查雙方戰爭的最後一張牌
                
                // 由於這裡的牌是蓋起來的，因此追蹤拿出來的牌的資訊是否有被正常添加。
                print("被添加到戰爭卡牌裡\(warCards.count)，玩家的前三張\(playerWarCards)，電腦的前三張\(computerWarCards)， 玩家的第四張\(playerWarLastCard)，電腦的第四張\(computerWarLastCard)")
                
                
                // 決定戰爭的贏家
                // 玩家的最後一張牌贏過電腦的最後一張牌。
                if playerRank > computerRank {

                    playerWonDeck.append(contentsOf: warCards)              // 戰爭贏家可以將戰爭的8張牌（各4張)添加到贏家的牌堆裡
                    playerWonDeck.append(contentsOf: originalCards)         // 戰爭贏家可以將導致戰爭的2張牌添加到贏家的牌堆裡
                    playerWonDeck.append(contentsOf: temporaryWarDeck)      // 將戰爭和局前出的戰爭牌也添加到贏家的牌堆裡 （只有戰爭狀態出現和局才有用）

                    // 將戰爭贏得的牌顯示在 playerWonCardImageView
                    let wonCardImageName = "\(playerWarLastCard.suit)_\(playerWarLastCard.rank)"
                    playerWonCardImageView.image = UIImage(named: wonCardImageName)

                    // 提示狀態、贏家牌堆的牌、雙方手上的牌的數量
                    playerWonCardAmount.text = "\(playerWonDeck.count)"
                    playerHandCardAmount.text = "\(playerDeck.count)"
                    computerHandCardAmount.text = "\(computerDeck.count)"
                    // 戰爭和局贏家可拿到的牌數
                    warCardWinnerCount += originalCards.count + warCards.count + temporaryWarDeck.count
                    hintLabel.text = "戰爭狀態！發生\(drawCount)次戰爭和局！玩家贏得戰爭！可拿\(warCardWinnerCount)張牌！"
                    playAudio(named: "Sword Sound", fileType: "mp3")

                    // 追蹤戰爭狀態結束後，拿出來戰爭的8牌、導致戰爭的2張牌是否有被正常添加到贏家的牌堆裡。戰爭和局累加的牌會被存放至 temporaryWarDeck，直到戰爭出現結果才會被分配。
                    print("玩家獲勝，將\(warCards)以及導致戰爭的\(originalCards)添加到贏得的牌裡，另外添加先前戰爭和局牌\(temporaryWarDeck)")

                }
                // 電腦的最後一張牌贏過玩家的最後一張牌。
                else if playerRank < computerRank {
                    computerWonDeck.append(contentsOf: warCards)            // 戰爭贏家可以將戰爭的8張牌（各4張)添加到贏家的牌堆裡
                    computerWonDeck.append(contentsOf: originalCards)       // 戰爭贏家可以將導致戰爭的2張牌添加到贏家的牌堆裡
                    computerWonDeck.append(contentsOf: temporaryWarDeck)    // 將戰爭和局前出的戰爭牌也添加到贏家的牌堆裡 （只有戰爭狀態出現和局才有用）

                    // 將戰爭贏得的牌顯示在 computerWonCardImageView
                    let wonCardImageName = "\(computerWarLastCard.suit)_\(computerWarLastCard.rank)"
                    computerWonCardImageView.image = UIImage(named: wonCardImageName)
                    
                    // 提示狀態、贏家牌堆的牌、雙方手上的牌的數量
                    hintLabel.text = "戰爭模式！電腦贏得戰爭！"
                    computerWonCardAmount.text = "\(computerWonDeck.count)"
                    playerHandCardAmount.text = "\(playerDeck.count)"
                    computerHandCardAmount.text = "\(computerDeck.count)"

                    // 戰爭和局贏家可拿到的牌數
                    warCardWinnerCount += originalCards.count + warCards.count + temporaryWarDeck.count
                    hintLabel.text = "戰爭狀態！發生\(drawCount)次戰爭和局！電腦贏得戰爭！可拿\(warCardWinnerCount)張牌！"
                    playAudio(named: "Sword Sound", fileType: "mp3")

                    // 追蹤戰爭狀態結束後，拿出來戰爭的8牌、導致戰爭的2張牌是否有被正常添加到贏家的牌堆裡。戰爭和局累加的牌會被存放至 temporaryWarDeck，直到戰爭出現結果才會被分配。
                    print("電腦獲勝，將\(warCards)以及導致戰爭的\(originalCards)添加到贏得的牌裡，另外添加先前戰爭和局牌\(temporaryWarDeck)")

                }
                // 如果戰爭狀態發生和局
                else {
                    // 表示發生了和局狀態
                    warDraw = true

                    // 控制牌面
                    handleWarState()
                }

                // 如果戰爭狀態發生和局為 true，則進入下一輪戰爭
                if warDraw {
                    // 將和局前出雙方出的牌存儲在暫時的牌堆中。
                    temporaryWarDeck.append(contentsOf: playerWarCards)                 // 玩家蓋起來的三張牌
                    temporaryWarDeck.append(contentsOf: computerWarCards)               // 電腦蓋起來的三張牌
                    temporaryWarDeck.append(playerWarLastCard)                          // 玩家掀開來的第四張牌
                    temporaryWarDeck.append(computerWarLastCard)                        // 電腦掀開來的第四張牌

                    // 添加戰爭和局次數
                    drawCount += 1
                    // 控制戰爭狀態
                    handleWarState()
                    // 將 warDraw 設置為 false，以確保可以進入下一輪戰爭
                    warDraw = false
                    // 檢查暫存牌庫的資訊是否正確
                    print("戰爭發生和局所儲存的牌數量\(temporaryWarDeck.count)，以及牌的資訊\(temporaryWarDeck)")
                    continue
                }

                // 控制戰爭狀態
                handleWarState()

                // 檢查戰爭狀態時的玩家手牌是否已經用完
                if playerDeck.isEmpty {
                    // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
                    if playerWonDeck.isEmpty {
                        playCardButton.isEnabled = false
                        hintLabel.text = "你已經沒牌了！電腦獲勝！"
                        print("遊戲結束，電腦贏。")
                        return
                    }
                    // 如果贏得的牌還有牌，則洗牌後添加回手牌中
                    else {
                        playerWonDeck.shuffle()
                        playerDeck.append(contentsOf: playerWonDeck)
                        playerWonDeck.removeAll()
                    }
                }

                // 檢查戰爭狀態時的電腦手牌是否已經用完
                if computerDeck.isEmpty {
                    // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
                    if computerWonDeck.isEmpty {
                        playCardButton.isEnabled = false
                        hintLabel.text = "電腦已經沒牌了！玩家獲勝！"
                        print("遊戲結束, 玩家贏")
                        return
                    }
                    // 如果贏得的牌還有牌，則洗牌後添加回手牌中
                    else {
                        computerWonDeck.shuffle()
                        computerDeck.append(contentsOf: computerWonDeck)
                        computerWonDeck.removeAll()
                    }
                }

                // 在這裡添加 playCardButton.isEnabled = false
                playCardButton.isEnabled = false

            }

        }

    }

    // 音效使用
    func playAudio(named fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("無法找到指定的音訊檔案")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        soundPlayer.replaceCurrentItem(with: playerItem)
        soundPlayer.play()
    }


    // 建立完整的牌
    func createFullDeck() {
        // 撲克牌花色、數字
        let suits = ["clubs", "diamonds", "hearts", "spades"]
        let ranks = Array(1...13)
        // 建立完整的牌
        for suit in suits {
            for rank in ranks {
                let card = Card(suit: suit, rank: rank)                 //創建每張牌
                fullDeck.append(card)                                   //加入到全牌堆
            }
        }
    }

    // 洗牌
    func shuffleDeck(deck: inout [Card]) {
        deck.shuffle()
    }

    // 設置戰爭狀態
    func handleWarState() {

        // 進入戰爭時，禁用按鈕
        playCardButton.isEnabled = false

        // 顯示戰爭的牌，並在延遲後隱藏戰爭的牌
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in 0...2 {
                self.playerWarCardImageViews[i].isHidden = true
                self.computerWarCardImageViews[i].isHidden = true
 
            }
            // 隱藏圖片
            self.playerWarLastCardImageView.isHidden = true
            self.computerWarLastCardImageView.isHidden = true
            // 啟用按鈕
            self.playCardButton.isEnabled = true
        }
    }


    // 重置按鈕
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // 重置電腦及玩家的牌庫
        playerDeck = []
        computerDeck = []
        fullDeck = []
        playerWonDeck = []
        computerWonDeck = []

        // 重建完整的牌並洗牌
        createFullDeck()                                            // 呼叫創建完整的牌的函數
        shuffleDeck(deck: &fullDeck)                                // 呼叫洗牌的function，將完整的牌做洗牌
        playerDeck = Array(fullDeck[0..<26])                        // 玩家得到的牌
        computerDeck = Array(fullDeck[26..<52])                     // 電腦得到的牌

        // 重置所有圖片、提示
        playerCardImageView.image = nil
        computerCardImageView.image = nil
        playerWonCardImageView.image = nil
        computerWonCardImageView.image = nil
        hintLabel.text = "請出牌！"
        playerWonCardAmount.text = "\(playerWonDeck.count)"
        computerWonCardAmount.text = "\(computerWonDeck.count)"
        playerHandCardAmount.text = "\(playerDeck.count)"
        computerHandCardAmount.text = "\(computerDeck.count)"

        // 重置戰爭相關的UI元素
        for i in 0...2 {
            playerWarCardImageViews[i].isHidden = true
            computerWarCardImageViews[i].isHidden = true
        }
        // 隱藏圖片
        self.playerWarLastCardImageView.isHidden = true
        self.computerWarLastCardImageView.isHidden = true

        // 啟用出牌按鈕
         playCardButton.isEnabled = true
    }

}




//// 新版（一次抽取四張牌）
//import UIKit
//import AVFoundation
//
//class ViewController: UIViewController {
//
//    // 戰爭狀態時玩家、電腦的卡牌，有4個outlet
//    @IBOutlet var playerWarCardImageViews: [UIImageView]!
//    @IBOutlet var computerWarCardImageViews: [UIImageView]!
//    // 各自贏得的撲克牌
//    @IBOutlet weak var playerWonCardImageView: UIImageView!
//    @IBOutlet weak var computerWonCardImageView: UIImageView!
//    // 玩家出的牌、電腦出的牌
//    @IBOutlet weak var playerCardImageView: UIImageView!
//    @IBOutlet weak var computerCardImageView: UIImageView!
//    // 出牌 UIButton 的 Outlet
//    @IBOutlet weak var playCardButton: UIButton!
//    // 狀態提示文字
//    @IBOutlet weak var hintLabel: UILabel!
//    // 顯示當前贏得的牌數
//    @IBOutlet weak var playerWonCardAmount: UILabel!
//    @IBOutlet weak var computerWonCardAmount: UILabel!
//    // 顯示當前手上的牌數
//    @IBOutlet weak var playerHandCardAmount: UILabel!
//    @IBOutlet weak var computerHandCardAmount: UILabel!
//
//    // 玩家的牌
//    var playerDeck = [Card]()
//    // 電腦的牌
//    var computerDeck = [Card]()
//    // 完整的牌組
//    var fullDeck = [Card]()
//    // 存放玩家、電腦贏得的牌
//    var playerWonDeck = [Card]()
//    var computerWonDeck = [Card]()
//
//    // 音效播放
//    let soundPlayer = AVPlayer()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 建立完整的牌
//        createFullDeck()
//
//        // 洗牌並將牌平分給玩家以及電腦
//        shuffleDeck(deck: &fullDeck)
//        playerDeck = Array(fullDeck[0..<26])
//        computerDeck = Array(fullDeck[26..<52])
//
//        // 初始化狀態提示文字與目前的牌數（贏得的牌、手上的牌）
//        hintLabel.text = "請出牌！"
//        playerWonCardAmount.text = "\(playerWonDeck.count)"
//        computerWonCardAmount.text = "\(computerWonDeck.count)"
//        playerHandCardAmount.text = "\(playerDeck.count)"
//        computerHandCardAmount.text = "\(computerDeck.count)"
//    }
//
//    // 點擊後出牌
//    @IBAction func playCard(_ sender: UIButton) {
//        playAudio(named: "CardDrop", fileType: "mp3")
//        // 玩家與電腦都有牌時
//        if !playerDeck.isEmpty && !computerDeck.isEmpty {
//
//            // 取出各自撲克牌的第一張牌
//            let playerCard = playerDeck.removeFirst()
//            let computerCard = computerDeck.removeFirst()
//
//            // 將取出的撲克牌顯示在 UIImageView 上
//            let playerImageName = "\(playerCard.suit)_\(playerCard.rank)"
//            let computerImageName = "\(computerCard.suit)_\(computerCard.rank)"
//            playerCardImageView.image = UIImage(named: playerImageName)
//            computerCardImageView.image = UIImage(named: computerImageName)
//
//            // 如果牌是 A，則將其數值設為最大的數字
//            var playerRank = playerCard.rank == 1 ? 14 : playerCard.rank
//            var computerRank = computerCard.rank == 1 ? 14 : computerCard.rank
//
//            // 比較玩家與電腦的牌數字的大小，並決定誰贏
//            // 玩家贏
//            if playerRank > computerRank {
//                // 玩家贏得電腦的牌，將這兩張牌加到 「玩家贏得的牌」
//                playerWonDeck.append(contentsOf: [playerCard, computerCard])
//
//                // 顯示贏得的牌
//                let playerWonImageName = "\(playerCard.suit)_\(playerCard.rank)"
//                playerWonCardImageView.image = UIImage(named: playerWonImageName)
//
//                // 顯示玩家贏得的牌的數量
//                playerWonCardAmount.text = "\(playerWonDeck.count)"
//
//                // 顯示手上的牌的數量
//                playerHandCardAmount.text = "\(playerDeck.count)"
//                computerHandCardAmount.text = "\(computerDeck.count)"
//
//                // 提示文字
//                hintLabel.text = "玩家數字比較大！玩家拿牌！"
//
//                print("玩家贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
//                print("玩家贏,玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )
//
//            }
//            // 電腦贏
//            else if playerRank < computerRank {
//                // 電腦贏得玩家的牌，將這兩張牌加到 「電腦贏得的牌」
//                computerWonDeck.append(contentsOf: [playerCard, computerCard])
//
//                // 顯示贏得的牌
//                let computerWonImageName = "\(computerCard.suit)_\(computerCard.rank)"
//                computerWonCardImageView.image = UIImage(named: computerWonImageName)
//
//                // 顯示電腦贏得的牌的數量
//                computerWonCardAmount.text = "\(computerWonDeck.count)"
//
//                // 顯示手上的牌的數量
//                playerHandCardAmount.text = "\(playerDeck.count)"
//                computerHandCardAmount.text = "\(computerDeck.count)"
//
//                // 提示文字
//                hintLabel.text = "電腦數字比較大！電腦拿牌！"
//
//                print("電腦贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
//                print("電腦贏, 玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )
//            }
//
//
//            // 如果玩家的手牌已經空了
//            if playerDeck.isEmpty {
//                // 檢查玩家贏得的牌是否用完
//                if playerWonDeck.isEmpty {
//                    // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "玩家牌不夠！電腦贏了！"
//                    print("遊戲結束, 電腦贏")
//                    return
//                }
//                // 如果玩家贏得的牌庫裡還有牌
//                else {
//                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
//                    playerWonDeck.shuffle()
//                    playerDeck.append(contentsOf: playerWonDeck)
//                    playerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量、並且清空玩家贏得的牌庫imageView
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    playerWonCardImageView.image = nil
//                }
//            }
//
//            // 如果電腦的手牌已經空了
//            if computerDeck.isEmpty {
//                // 檢查電腦贏得的牌是否用完
//                if computerWonDeck.isEmpty {
//                    // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "電腦牌不夠！玩家贏了！"
//                    print("遊戲結束, 玩家贏")
//                    return
//                }
//                // 如果電腦贏得的牌庫裡還有牌
//                else {
//                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
//                    computerWonDeck.shuffle()
//                    computerDeck.append(contentsOf: computerWonDeck)
//                    computerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量、並且清空電腦贏得的牌庫imageView
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    computerWonCardImageView.image = nil
//                }
//            }
//
//
//            // 處理戰爭的情況，戰爭是否發生和局
//            var warDraw = false
//            // 計算戰爭和局贏家可拿的牌
//            var warCardWinnerCount: Int = 0
//            // 紀錄戰爭和局的次數
//            var drawCount: Int = 0
//            // 儲存戰爭期間的牌
//            var temporaryWarDeck: [Card] = []
//            // 空的撲克牌陣列來儲存戰爭中使用的卡牌
//            var warCards: [Card] = []
//            // 儲存導致戰爭狀態的兩張牌
//            var originalCards: [Card] = []
//
//            // 當雙方大小相同時，進入戰爭狀態
//            while playerRank == computerRank {
//
//                print("由於玩家\(playerRank), 電腦\(computerRank)一樣，因此進入戰爭狀態")     // 檢查導致戰爭的兩張牌的數字
//
//                // 如果戰爭和局，清空戰爭卡牌陣列，準備處理新一輪的戰爭，避免重複添加。
//                warCards.removeAll()
//                // 如果戰爭和局，清空導致戰爭狀態的兩張牌，避免重複添加。
//                originalCards.removeAll()
//
//                // 導致戰爭的兩張牌
//                originalCards.append(playerCard)
//                originalCards.append(computerCard)
//                print("儲存導致戰爭的牌\(originalCards)")                                   // 檢查導致戰爭的兩張牌是否有被正常添加
//
//                // 檢查玩家是否有足夠的牌（發動戰爭需要 4 張牌）
//                if playerDeck.count < 4 && (playerDeck.count + playerWonDeck.count) < 4 {
//
//                    // 如果玩家的牌和贏得的牌都不夠，那麼遊戲結束
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "玩家的牌不夠進行戰爭！玩家輸了！"
//                    print("遊戲結束，玩家輸了")
//                    return
//                }
//                // 如果贏得的牌堆有足夠的牌，將贏得的牌堆洗牌，然後放入手牌中
//                else {
//                    shuffleDeck(deck: &playerWonDeck)
//                    playerDeck.append(contentsOf: playerWonDeck)
//                    playerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    playerWonCardImageView.image = nil
//                    print("戰爭狀態玩家當前牌\(playerDeck.count)太少，因此加入贏得的\(playerWonDeck.count)牌")
//                }
//
//                // 檢查電腦是否有足夠的牌（發動戰爭需要 4 張牌）
//                if computerDeck.count < 4 && (computerDeck.count + computerWonDeck.count) < 4 {
//
//                    // 如果電腦的牌和贏得的牌都不夠，那麼遊戲結束
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "電腦的牌不夠進行戰爭！電腦輸了！"
//                    print("遊戲結束，電腦輸了")
//                    return
//                }
//                // 如果電腦的牌數和贏得的牌數合起來至少有 4 張，則執行其他處理邏輯
//                else {
//                    // 如果電腦的牌數和贏得的牌數合起來至少有 4 張，則執行其他處理邏輯
//                    shuffleDeck(deck: &computerWonDeck)
//                    computerDeck.append(contentsOf: computerWonDeck)
//                    computerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    computerWonCardImageView.image = nil
//                    print("戰爭狀態電腦當前牌\(computerDeck.count)太少，因此加入贏得的\(computerWonDeck.count)牌")
//                }
//
//
//                // 移除雙方的前四張牌進入 "戰爭"。
//                let playerWarCards = Array(playerDeck.prefix(4))
//                playerDeck.removeFirst(4)
//                let computerWarCards = Array(computerDeck.prefix(4))
//                computerDeck.removeFirst(4)
//
//                // 將這些卡牌也添加到戰爭卡牌陣列中
//                warCards.append(contentsOf: playerWarCards)
//                warCards.append(contentsOf: computerWarCards)
//
//                // 由於這裡的牌是蓋起來的，因此追蹤拿出來的牌的資訊是否有被正常添加。
//                print("被添加到戰爭卡牌裡\(warCards.count), 玩家的前四張\(playerWarCards), 電腦的前四張\(computerWarCards)")
//
//                // 雙方前三張牌顯示卡背。
//                for i in 0..<3 {
//                    playerWarCardImageViews[i].image = UIImage(named: "card_back")
//                    playerWarCardImageViews[i].isHidden = false
//                    computerWarCardImageViews[i].image = UIImage(named: "card_back")
//                    computerWarCardImageViews[i].isHidden = false
//                }
//
//                // 將雙方最後一張牌設置為正面，並且顯示。
//                let playerImageName = "\(playerWarCards[3].suit)_\(playerWarCards[3].rank)"
//                playerWarCardImageViews[3].image = UIImage(named: playerImageName)
//                playerWarCardImageViews[3].isHidden = false
//                let computerImageName = "\(computerWarCards[3].suit)_\(computerWarCards[3].rank)"
//                computerWarCardImageViews[3].image = UIImage(named: computerImageName)
//                computerWarCardImageViews[3].isHidden = false
//
//                // 比較雙方最後一張牌
//                let playerCard = playerWarCards.last!
//                let computerCard = computerWarCards.last!
//                // 將A的數字調整為14最大
//                playerRank = playerCard.rank == 1 ? 14 : playerCard.rank
//                computerRank = computerCard.rank == 1 ? 14 : computerCard.rank
//                print("戰爭狀態：玩家的最後一張\(playerCard.rank), 電腦的最後一張\(computerCard.rank)")   // 檢查雙方戰爭的最後一張牌
//
//                // 決定戰爭的贏家
//                // 玩家的最後一張牌贏過電腦的最後一張牌。
//                if playerRank > computerRank {
//
//                    playerWonDeck.append(contentsOf: warCards)              // 戰爭贏家可以將戰爭的8張牌（各4張)添加到贏家的牌堆裡
//                    playerWonDeck.append(contentsOf: originalCards)         // 戰爭贏家可以將導致戰爭的2張牌添加到贏家的牌堆裡
//                    playerWonDeck.append(contentsOf: temporaryWarDeck)      // 將戰爭和局前出的戰爭牌也添加到贏家的牌堆裡 （只有戰爭狀態出現和局才有用）
//
//                    // 將戰爭贏得的牌顯示在 playerWonCardImageView
//                    let wonCardImageName = "\(playerCard.suit)_\(playerCard.rank)"
//                    playerWonCardImageView.image = UIImage(named: wonCardImageName)
//
//                    // 提示狀態、贏家牌堆的牌、雙方手上的牌的數量
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    // 戰爭和局贏家可拿到的牌數
//                    warCardWinnerCount += originalCards.count + warCards.count + temporaryWarDeck.count
//                    hintLabel.text = "戰爭狀態！發生\(drawCount)次戰爭和局！玩家贏得戰爭！可拿\(warCardWinnerCount)張牌！"
//                    playAudio(named: "Sword Sound", fileType: "mp3")
//
//                    // 追蹤戰爭狀態結束後，拿出來戰爭的8牌、導致戰爭的2張牌是否有被正常添加到贏家的牌堆裡。戰爭和局累加的牌會被存放至 temporaryWarDeck，直到戰爭出現結果才會被分配。
//                    print("玩家獲勝，將\(warCards)以及導致戰爭的\(originalCards)添加到贏得的牌裡，另外添加先前戰爭和局牌\(temporaryWarDeck)")
//
//                }
//                // 電腦的最後一張牌贏過玩家的最後一張牌。
//                else if playerRank < computerRank {
//                    computerWonDeck.append(contentsOf: warCards)            // 戰爭贏家可以將戰爭的8張牌（各4張)添加到贏家的牌堆裡
//                    computerWonDeck.append(contentsOf: originalCards)       // 戰爭贏家可以將導致戰爭的2張牌添加到贏家的牌堆裡
//                    computerWonDeck.append(contentsOf: temporaryWarDeck)    // 將戰爭和局前出的戰爭牌也添加到贏家的牌堆裡 （只有戰爭狀態出現和局才有用）
//
//                    // 將戰爭贏得的牌顯示在 computerWonCardImageView
//                    let wonCardImageName = "\(computerCard.suit)_\(computerCard.rank)"
//                    computerWonCardImageView.image = UIImage(named: wonCardImageName)
//                    // 提示狀態、贏家牌堆的牌、雙方手上的牌的數量
//                    hintLabel.text = "戰爭模式！電腦贏得戰爭！"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//
//                    // 戰爭和局贏家可拿到的牌數
//                    warCardWinnerCount += originalCards.count + warCards.count + temporaryWarDeck.count
//                    hintLabel.text = "戰爭狀態！發生\(drawCount)次戰爭和局！電腦贏得戰爭！可拿\(warCardWinnerCount)張牌！"
//                    playAudio(named: "Sword Sound", fileType: "mp3")
//
//                    // 追蹤戰爭狀態結束後，拿出來戰爭的8牌、導致戰爭的2張牌是否有被正常添加到贏家的牌堆裡。戰爭和局累加的牌會被存放至 temporaryWarDeck，直到戰爭出現結果才會被分配。
//                    print("電腦獲勝，將\(warCards)以及導致戰爭的\(originalCards)添加到贏得的牌裡，另外添加先前戰爭和局牌\(temporaryWarDeck)")
//
//                }
//                // 如果戰爭狀態發生和局
//                else {
//                    // 表示發生了和局狀態
//                    warDraw = true
//
//                    // 控制牌面
//                    handleWarState()
//                }
//
//                // 如果戰爭狀態發生和局為 true，則進入下一輪戰爭
//                if warDraw {
//                    // 將和局前出雙方出的牌存儲在暫時的牌堆中。
//                    temporaryWarDeck.append(contentsOf: playerWarCards)
//                    temporaryWarDeck.append(contentsOf: computerWarCards)
//                    // 添加戰爭和局次數
//                    drawCount += 1
//                    // 控制戰爭狀態
//                    handleWarState()
//                    // 將 warDraw 設置為 false，以確保可以進入下一輪戰爭
//                    warDraw = false
//                    // 檢查暫存牌庫的資訊是否正確
//                    print("戰爭發生和局所儲存的牌數量\(temporaryWarDeck.count)，以及牌的資訊\(temporaryWarDeck)")
//                    continue
//                }
//
//                // 控制戰爭狀態
//                handleWarState()
//
//                // 檢查戰爭狀態時的玩家手牌是否已經用完
//                if playerDeck.isEmpty {
//                    // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
//                    if playerWonDeck.isEmpty {
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "你已經沒牌了！電腦獲勝！"
//                        print("遊戲結束，電腦贏。")
//                        return
//                    }
//                    // 如果贏得的牌還有牌，則洗牌後添加回手牌中
//                    else {
//                        playerWonDeck.shuffle()
//                        playerDeck.append(contentsOf: playerWonDeck)
//                        playerWonDeck.removeAll()
//                    }
//                }
//
//                // 檢查戰爭狀態時的電腦手牌是否已經用完
//                if computerDeck.isEmpty {
//                    // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
//                    if computerWonDeck.isEmpty {
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "電腦已經沒牌了！玩家獲勝！"
//                        print("遊戲結束, 玩家贏")
//                        return
//                    }
//                    // 如果贏得的牌還有牌，則洗牌後添加回手牌中
//                    else {
//                        computerWonDeck.shuffle()
//                        computerDeck.append(contentsOf: computerWonDeck)
//                        computerWonDeck.removeAll()
//                    }
//                }
//
//                // 在這裡添加 playCardButton.isEnabled = false
//                playCardButton.isEnabled = false
//            }
//
//        }
//    }
//
//    // 音效使用
//    func playAudio(named fileName: String, fileType: String) {
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
//            print("無法找到指定的音訊檔案")
//            return
//        }
//
//        let playerItem = AVPlayerItem(url: url)
//        soundPlayer.replaceCurrentItem(with: playerItem)
//        soundPlayer.play()
//    }
//
//
//    // 建立完整的牌
//    func createFullDeck() {
//        // 撲克牌花色、數字
//        let suits = ["clubs", "diamonds", "hearts", "spades"]
//        let ranks = Array(1...13)
//        // 建立完整的牌
//        for suit in suits {
//            for rank in ranks {
//                let card = Card(suit: suit, rank: rank)                 //創建每張牌
//                fullDeck.append(card)                                   //加入到全牌堆
//            }
//        }
//    }
//
//    // 洗牌
//    func shuffleDeck(deck: inout [Card]) {
//        deck.shuffle()
//    }
//
//    // 設置戰爭狀態
//    func handleWarState() {
//
//        // 進入戰爭時，禁用按鈕
//        playCardButton.isEnabled = false
//
//        // 顯示戰爭的牌，並在延遲後隱藏戰爭的牌
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            for i in 0..<4 {
//                self.playerWarCardImageViews[i].isHidden = true
//                self.computerWarCardImageViews[i].isHidden = true
//            }
//            // 啟用按鈕
//            self.playCardButton.isEnabled = true
//        }
//    }
//
//
//    // 重置按鈕
//    @IBAction func resetButtonTapped(_ sender: UIButton) {
//        // 重置電腦及玩家的牌庫
//        playerDeck = []
//        computerDeck = []
//        fullDeck = []
//        playerWonDeck = []
//        computerWonDeck = []
//
//        // 重建完整的牌並洗牌
//        createFullDeck()                                            // 呼叫創建完整的牌的函數
//        shuffleDeck(deck: &fullDeck)                                // 呼叫洗牌的function，將完整的牌做洗牌
//        playerDeck = Array(fullDeck[0..<26])                        // 玩家得到的牌
//        computerDeck = Array(fullDeck[26..<52])                     // 電腦得到的牌
//
//        // 重置所有圖片、提示
//        playerCardImageView.image = nil
//        computerCardImageView.image = nil
//        playerWonCardImageView.image = nil
//        computerWonCardImageView.image = nil
//        hintLabel.text = "請出牌！"
//        playerWonCardAmount.text = "\(playerWonDeck.count)"
//        computerWonCardAmount.text = "\(computerWonDeck.count)"
//        playerHandCardAmount.text = "\(playerDeck.count)"
//        computerHandCardAmount.text = "\(computerDeck.count)"
//
//        // 重置戰爭相關的UI元素
//        for i in 0..<4 {
//            playerWarCardImageViews[i].isHidden = true
//            computerWarCardImageViews[i].isHidden = true
//        }
//
//        // 啟用出牌按鈕
//         playCardButton.isEnabled = true
//    }
//
//}




// 舊版（bug）
//import UIKit
//
//class ViewController: UIViewController {
//
//    // 戰爭狀態時玩家、電腦的卡牌，有4個outlet
//    @IBOutlet var playerWarCardImageViews: [UIImageView]!
//    @IBOutlet var computerWarCardImageViews: [UIImageView]!
//
//    // 各自贏得的撲克牌
//    @IBOutlet weak var playerWonCardImageView: UIImageView!
//    @IBOutlet weak var computerWonCardImageView: UIImageView!
//    // 玩家出的牌、電腦出的牌
//    @IBOutlet weak var playerCardImageView: UIImageView!
//    @IBOutlet weak var computerCardImageView: UIImageView!
//    // 出牌 UIButton 的 Outlet
//    @IBOutlet weak var playCardButton: UIButton!
//    // 狀態提示文字
//    @IBOutlet weak var hintLabel: UILabel!
//    // 顯示當前贏得的牌數
//    @IBOutlet weak var playerWonCardAmount: UILabel!
//    @IBOutlet weak var computerWonCardAmount: UILabel!
//    // 顯示當前手上的牌數
//    @IBOutlet weak var playerHandCardAmount: UILabel!
//    @IBOutlet weak var computerHandCardAmount: UILabel!
//
//    // 玩家的牌
//    var playerDeck = [Card]()
//    // 電腦的牌
//    var computerDeck = [Card]()
//    // 完整的牌組
//    var fullDeck = [Card]()
//
//    // 存放玩家、電腦贏得的牌
//    var playerWonDeck = [Card]()
//    var computerWonDeck = [Card]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 建立完整的牌
//        createFullDeck()
//
//        // 洗牌並將牌平分給玩家以及電腦
//        shuffleDeck(deck: &fullDeck)
//        playerDeck = Array(fullDeck[0..<26])
//        computerDeck = Array(fullDeck[26..<52])
//
//        // 初始化狀態提示文字與目前的牌數（贏得的牌、手上的牌）
//        hintLabel.text = "請出牌！"
//        playerWonCardAmount.text = "\(playerWonDeck.count)"
//        computerWonCardAmount.text = "\(computerWonDeck.count)"
//        playerHandCardAmount.text = "\(playerDeck.count)"
//        computerHandCardAmount.text = "\(computerDeck.count)"
//    }
//
//    // 點擊後出牌
//    @IBAction func playCard(_ sender: UIButton) {
//
//        // 玩家與電腦都有牌時
//        if !playerDeck.isEmpty && !computerDeck.isEmpty {
//
//            // 取出各自撲克牌的第一張牌
//            let playerCard = playerDeck.removeFirst()
//            let computerCard = computerDeck.removeFirst()
//
//            // 將取出的撲克牌顯示在 UIImageView 上
//            let playerImageName = "\(playerCard.suit)_\(playerCard.rank)"
//            let computerImageName = "\(computerCard.suit)_\(computerCard.rank)"
//            playerCardImageView.image = UIImage(named: playerImageName)
//            computerCardImageView.image = UIImage(named: computerImageName)
//
//            // 如果牌是 A，則將其數值設為最大的數字
//            var playerRank = playerCard.rank == 1 ? 14 : playerCard.rank
//            var computerRank = computerCard.rank == 1 ? 14 : computerCard.rank
//
//            // 比較玩家與電腦的牌數字的大小，並決定誰贏
//            // 玩家贏
//            if playerRank > computerRank {
//                // 玩家贏得電腦的牌，將這兩張牌加到 「玩家贏得的牌」
//                playerWonDeck.append(contentsOf: [playerCard, computerCard])
//
//                // 顯示贏得的牌
//                let playerWonImageName = "\(playerCard.suit)_\(playerCard.rank)"
//                playerWonCardImageView.image = UIImage(named: playerWonImageName)
//
//                // 顯示玩家贏得的牌的數量
//                playerWonCardAmount.text = "\(playerWonDeck.count)"
//
//                // 顯示手上的牌的數量
//                playerHandCardAmount.text = "\(playerDeck.count)"
//                computerHandCardAmount.text = "\(computerDeck.count)"
//
//                // 提示文字
//                hintLabel.text = "玩家數字比較大！玩家拿牌！"
//
//                print("玩家贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
//                print("玩家贏,玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )
//
//            }
//            // 電腦贏
//            else if playerRank < computerRank {
//                // 電腦贏得玩家的牌，將這兩張牌加到 「電腦贏得的牌」
//                computerWonDeck.append(contentsOf: [playerCard, computerCard])
//
//                // 顯示贏得的牌
//                let computerWonImageName = "\(computerCard.suit)_\(computerCard.rank)"
//                computerWonCardImageView.image = UIImage(named: computerWonImageName)
//
//                // 顯示電腦贏得的牌的數量
//                computerWonCardAmount.text = "\(computerWonDeck.count)"
//
//                // 顯示手上的牌的數量
//                playerHandCardAmount.text = "\(playerDeck.count)"
//                computerHandCardAmount.text = "\(computerDeck.count)"
//
//                // 提示文字
//                hintLabel.text = "電腦數字比較大！電腦拿牌！"
//
//                print("電腦贏, 玩家目前的牌：\(playerDeck.count), 電腦目前的牌：\(computerDeck.count)" )
//                print("電腦贏, 玩家贏得的牌: \(playerWonDeck.count), 電腦贏得的牌：\(computerWonDeck.count)" )
//            }
//
//
//            // 如果玩家的手牌已經空了
//            if playerDeck.isEmpty {
//                // 檢查玩家贏得的牌是否用完
//                if playerWonDeck.isEmpty {
//                    // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "玩家牌不夠！電腦贏了！"
//                    print("遊戲結束, 電腦贏")
//                    return
//                }
//                // 如果玩家贏得的牌庫裡還有牌
//                else {
//                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
//                    playerWonDeck.shuffle()
//                    playerDeck = playerWonDeck
//                    playerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量、並且清空玩家贏得的牌庫imageView
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    playerWonCardImageView.image = nil
//                }
//            }
//
//            // 如果電腦的手牌已經空了
//            if computerDeck.isEmpty {
//                // 檢查電腦贏得的牌是否用完
//                if computerWonDeck.isEmpty {
//                    // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
//                    playCardButton.isEnabled = false
//                    hintLabel.text = "電腦牌不夠！玩家贏了！"
//                    print("遊戲結束, 玩家贏")
//                    return
//                }
//                // 如果電腦贏得的牌庫裡還有牌
//                else {
//                    // 將「贏得的牌」堆洗牌，然後放入手牌中，並且清空「贏得的牌」
//                    computerWonDeck.shuffle()
//                    computerDeck = computerWonDeck
//                    computerWonDeck.removeAll()
//
//                    // 顯示手上的牌的數量、並且清空電腦贏得的牌庫imageView
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//                    computerWonCardImageView.image = nil
//                }
//            }
//
//
//            // 處理戰爭的情況，戰爭是否發生和局
//            var warDraw = false
//            // 儲存戰爭期間的牌
//            var temporaryWarDeck: [Card] = []
//            // 空的撲克牌陣列來儲存戰爭中使用的卡牌
//            var warCards: [Card] = []
//
//            // 當雙方大小相同時，進入戰爭狀態
//            while playerRank == computerRank {
//
//                print("由於玩家\(playerRank), 電腦\(computerRank)一樣，因此進入戰爭狀態")
//
//                // 清空戰爭卡牌陣列，準備處理新一輪的戰爭
//                warCards.removeAll()
//
//                // 檢查玩家是否有足夠的牌（發動戰爭需要 4 張牌）
//                if playerDeck.count < 4 {
//
//                    // 如果玩家沒有足夠的牌來進行戰爭，檢查贏得的牌堆是否有足夠的牌
//                    if playerWonDeck.count < 4 {
//
//                        // 如果玩家的牌和贏得的牌都不夠，那麼遊戲結束
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "玩家的牌不夠進行戰爭！玩家輸了！"
//                        print("遊戲結束，玩家輸了")
//                        return
//                    }
//                    // 如果贏得的牌堆有足夠的牌，將贏得的牌堆洗牌，然後放入手牌中
//                    else {
//                        shuffleDeck(deck: &playerWonDeck)
//                        playerDeck.append(contentsOf: playerWonDeck)
//                        playerWonDeck.removeAll()
//
//                        // 顯示手上的牌的數量
//                        playerWonCardAmount.text = "\(playerWonDeck.count)"
//                        computerWonCardAmount.text = "\(computerWonDeck.count)"
//                        playerHandCardAmount.text = "\(playerDeck.count)"
//                        computerHandCardAmount.text = "\(computerDeck.count)"
//                        playerWonCardImageView.image = nil
//                        print("戰爭狀態玩家當前牌太少，因此加入贏得的牌")
//                    }
//                }
//
//
//                // 檢查電腦是否有足夠的牌（發動戰爭需要 4 張牌）
//                if computerDeck.count < 4 {
//
//                    // 如果電腦沒有足夠的牌來進行戰爭，檢查贏得的牌堆是否有足夠的牌
//                    if computerWonDeck.count < 4 {
//
//                        // 如果電腦的牌和贏得的牌都不夠，那麼遊戲結束
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "電腦的牌不夠進行戰爭！電腦輸了！"
//                        print("遊戲結束，電腦輸了")
//                        return
//                    }
//                    // 如果贏得的牌堆有足夠的牌，將贏得的牌堆洗牌，然後放入手牌中
//                    else {
//                        shuffleDeck(deck: &computerWonDeck)
//                        computerDeck.append(contentsOf: computerWonDeck)
//                        computerWonDeck.removeAll()
//
//                        // 顯示手上的牌的數量
//                        playerWonCardAmount.text = "\(playerWonDeck.count)"
//                        computerWonCardAmount.text = "\(computerWonDeck.count)"
//                        playerHandCardAmount.text = "\(playerDeck.count)"
//                        computerHandCardAmount.text = "\(computerDeck.count)"
//                        computerWonCardImageView.image = nil
//
//                        print("戰爭狀態電腦當前牌太少，因此加入贏得的牌")
//                    }
//                }
//
//
//                // 移除雙方的前四張牌進入 "戰爭"
//                let playerWarCards = Array(playerDeck.prefix(4))
//                playerDeck.removeFirst(4)
//                let computerWarCards = Array(computerDeck.prefix(4))
//                computerDeck.removeFirst(4)
//
//                // 將這些卡牌也添加到戰爭卡牌陣列中
//                warCards.append(contentsOf: playerWarCards)
//                warCards.append(contentsOf: computerWarCards)
//
//                print("被添加到戰爭卡牌裡\(warCards.count), 玩家的前四張\(playerWarCards), 電腦的前四張\(computerWarCards)")
//
//                // 前三張牌蓋起來，並且顯示
//                for i in 0..<3 {
//                    playerWarCardImageViews[i].image = UIImage(named: "card_back")
//                    playerWarCardImageViews[i].isHidden = false
//                    computerWarCardImageViews[i].image = UIImage(named: "card_back")
//                    computerWarCardImageViews[i].isHidden = false
//                }
//
//                // 將最後一張牌設置為正面，並且顯示
//                let playerImageName = "\(playerWarCards[3].suit)_\(playerWarCards[3].rank)"
//                playerWarCardImageViews[3].image = UIImage(named: playerImageName)
//                playerWarCardImageViews[3].isHidden = false
//                let computerImageName = "\(computerWarCards[3].suit)_\(computerWarCards[3].rank)"
//                computerWarCardImageViews[3].image = UIImage(named: computerImageName)
//                computerWarCardImageViews[3].isHidden = false
//
//                // 比較雙方最後一張牌
//                let playerCard = playerWarCards.last!
//                let computerCard = computerWarCards.last!
//                // 將A的數字調整為14最大
//                playerRank = playerCard.rank == 1 ? 14 : playerCard.rank
//                computerRank = computerCard.rank == 1 ? 14 : computerCard.rank
//                print("戰爭狀態：玩家的最後一張\(playerCard.rank), 電腦的最後一張\(computerCard.rank)")
//
//
//                // 將剛剛比較的卡牌添加到戰爭卡牌陣列中 （測試）
//                // 應該是要將原先導致戰爭的兩張牌給加入到warCards
//                warCards.append(playerCard)
//                warCards.append(computerCard)
//
//                print(warCards.count, playerCard.rank, computerCard.rank)
//
//                // 決定戰爭的贏家
//                if playerRank > computerRank {
//                    // 玩家贏
//                    playerWonDeck.append(contentsOf: warCards)
//                    playerWonDeck.append(contentsOf: temporaryWarDeck)  // 將和局前出的牌也給玩家
//
//                    // 將戰爭贏得的牌顯示在playerWonCardImageView
//                    let wonCardImageName = "\(playerCard.suit)_\(playerCard.rank)"
//                    playerWonCardImageView.image = UIImage(named: wonCardImageName)
//                    hintLabel.text = "戰爭模式！玩家贏得戰爭！"
//                    playerWonCardAmount.text = "\(playerWonDeck.count)"
//
//                    // 顯示手上的牌的數量
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//
//                    print("玩家獲勝，將\(warCards)添加到贏得的牌裡")
//                } else if playerRank < computerRank {
//                    // 電腦贏
//                    computerWonDeck.append(contentsOf: warCards)
//                    computerWonDeck.append(contentsOf: temporaryWarDeck)  // 將和局前出的牌也給電腦
//
//                    // 將戰爭贏得的牌顯示在computerWonCardImageView
//                    let wonCardImageName = "\(computerCard.suit)_\(computerCard.rank)"
//                    computerWonCardImageView.image = UIImage(named: wonCardImageName)
//                    hintLabel.text = "戰爭模式！電腦贏得戰爭！"
//                    computerWonCardAmount.text = "\(computerWonDeck.count)"
//
//                    // 顯示手上的牌的數量
//                    playerHandCardAmount.text = "\(playerDeck.count)"
//                    computerHandCardAmount.text = "\(computerDeck.count)"
//
//                    print("電腦獲勝，將\(warCards)添加到贏得的牌裡")
//                } else {
//                    // 戰爭狀態發生和局
//                    warDraw = true
//
//                    // 測試
//                    handleWarState()
//                    hintLabel.text = "戰爭模式！目前是和局！"
//
//                    print("戰爭狀態和局")
//                }
//
//                // 和局狀態下：清空戰爭卡牌陣列，為可能發生的下一次戰爭做準備
//                warCards.removeAll()
//                temporaryWarDeck.removeAll()
//
//                // 檢查是否發生和局，如果是則進入下一輪戰爭
//                if warDraw {
//                    // 將和局前出的牌存儲在暫時的牌堆中
//                    temporaryWarDeck.append(contentsOf: playerWarCards)
//                    temporaryWarDeck.append(contentsOf: computerWarCards)
//
//                    // 控制戰爭狀態
//                    handleWarState()
//
//                    warDraw = false  // 將 warDraw 設置為 false，以確保可以進入下一輪戰爭
//                    continue
//                }
//
//                // 控制戰爭狀態
//                handleWarState()
//
//                // 檢查玩家的手牌是否已經用完
//                if playerDeck.isEmpty {
//                    if playerWonDeck.isEmpty {
//                        // 如果玩家的牌和贏得的牌都用完了，那麼遊戲結束，電腦贏
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "你已經沒牌了！電腦獲勝！"
//                        print("遊戲結束，電腦贏。")
//                        return
//                    } else {
//                        // 如果用完，將贏得的牌堆洗牌，然後放入手牌中
//                        playerWonDeck.shuffle()
//                        playerDeck = playerWonDeck
//                        // 清空贏得的牌堆
//                        playerWonDeck.removeAll()
//                    }
//                }
//
//                // 檢查電腦的手牌是否已經用完
//                if computerDeck.isEmpty {
//                    if computerWonDeck.isEmpty {
//                        // 如果電腦的牌和贏得的牌都用完了，那麼遊戲結束，玩家贏
//                        playCardButton.isEnabled = false
//                        hintLabel.text = "電腦已經沒牌了！玩家獲勝！"
//                        print("遊戲結束, 玩家贏")
//                        return
//                    } else {
//                        computerWonDeck.shuffle()
//                        computerDeck = computerWonDeck
//                        computerWonDeck.removeAll()
//                    }
//                }
//
//                // 在這裡添加 playCardButton.isEnabled = false
//                playCardButton.isEnabled = false
//
//            }
//
//        }
//
//
//    }
//
//    // 建立完整的牌
//    func createFullDeck() {
//        // 撲克牌花色、數字
//        let suits = ["clubs", "diamonds", "diamonds", "spades"]
//        let ranks = Array(1...13)
//        // 建立完整的牌
//        for suit in suits {
//            for rank in ranks {
//                let card = Card(suit: suit, rank: rank)                 //創建每張牌
//                fullDeck.append(card)                                   //加入到全牌堆
//            }
//        }
//    }
//
//    // 洗牌
//    func shuffleDeck(deck: inout [Card]) {
//        deck.shuffle()
//    }
//
//    // 設置戰爭狀態
//    func handleWarState() {
//
//        // 進入戰爭時，禁用按鈕
//        playCardButton.isEnabled = false
//
//        // 顯示戰爭的牌，並在延遲後隱藏戰爭的牌
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            for i in 0..<4 {
//                self.playerWarCardImageViews[i].isHidden = true
//                self.computerWarCardImageViews[i].isHidden = true
//            }
//            // 啟用按鈕
//            self.playCardButton.isEnabled = true
//        }
//    }
//
//
//    // 重置按鈕
//    @IBAction func resetButtonTapped(_ sender: UIButton) {
//        // 重置電腦及玩家的牌庫
//        playerDeck = []
//        computerDeck = []
//        fullDeck = []
//        playerWonDeck = []
//        computerWonDeck = []
//
//        // 重建完整的牌並洗牌
//        createFullDeck()                                            // 呼叫創建完整的牌的函數
//        shuffleDeck(deck: &fullDeck)                                // 呼叫洗牌的function，將完整的牌做洗牌
//        playerDeck = Array(fullDeck[0..<26])                        // 玩家得到的牌
//        computerDeck = Array(fullDeck[26..<52])                     // 電腦得到的牌
//
//        // 重置所有圖片、提示
//        playerCardImageView.image = nil
//        computerCardImageView.image = nil
//        playerWonCardImageView.image = nil
//        computerWonCardImageView.image = nil
//        hintLabel.text = "請出牌！"
//        playerWonCardAmount.text = "\(playerWonDeck.count)"
//        computerWonCardAmount.text = "\(computerWonDeck.count)"
//        playerHandCardAmount.text = "\(playerDeck.count)"
//        computerHandCardAmount.text = "\(computerDeck.count)"
//
//        // 重置戰爭相關的UI元素
//        for i in 0..<4 {
//            playerWarCardImageViews[i].isHidden = true
//            computerWarCardImageViews[i].isHidden = true
//        }
//
//        // 啟用出牌按鈕
//         playCardButton.isEnabled = true
//
//    }
//
//}







