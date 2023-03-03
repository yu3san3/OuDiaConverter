import Foundation

//データ例
let exampleOudText = """
FileType=OuDia.1.02
Rosen.
Rosenmei=
Eki.
Ekimei=A駅
Ekijikokukeisiki=Jikokukeisiki_NoboriChaku
Ekikibo=Ekikibo_Ippan
.
Eki.
Ekimei=B駅
Ekijikokukeisiki=Jikokukeisiki_Hatsuchaku
Ekikibo=Ekikibo_Ippan
.
Eki.
Ekimei=C駅
Ekijikokukeisiki=Jikokukeisiki_KudariChaku
Ekikibo=Ekikibo_Ippan
.
Ressyasyubetsu.
Syubetsumei=普通
JikokuhyouMojiColor=00000000
JikokuhyouFontIndex=0
DiagramSenColor=00000000
DiagramSenStyle=SenStyle_Jissen
StopMarkDrawType=EStopMarkDrawType_DrawOnStop
.
Ressyasyubetsu.
Syubetsumei=特別急行
Ryakusyou=特急
JikokuhyouMojiColor=000000FF
JikokuhyouFontIndex=0
DiagramSenColor=000000FF
DiagramSenStyle=SenStyle_Jissen
StopMarkDrawType=EStopMarkDrawType_DrawOnStop
.
Dia.
DiaName=例
Kudari.
Ressya.
Houkou=Kudari
Syubetsu=0
Ressyabangou=101
EkiJikoku=1;800,1;810/815,1;830/
.
Ressya.
Houkou=Kudari
Syubetsu=1
Ressyabangou=1
EkiJikoku=1;805,2,1;825/
.
.
Nobori.
.
.
Dia.
DiaName=例2
Kudari.
Ressya.
Houkou=Kudari
Syubetsu=0
Ressyabangou=101
EkiJikoku=1;800,1;810/815,1;830/
.
.
Nobori.
Ressya.
Houkou=Nobori
Syubetsu=0
Ressyabangou=102
EkiJikoku=1;800,1;810/815,1;830/
.
.
.
KitenJikoku=000
DiagramDgrYZahyouKyoriDefault=60
Comment=
.
DispProp.
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック;Bold=1
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック;Itaric=1
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック;Bold=1;Itaric=1
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック
JikokuhyouFont=PointTextHeight=9;Facename=ＭＳ ゴシック
JikokuhyouVFont=PointTextHeight=9;Facename=@ＭＳ ゴシック
DiaEkimeiFont=PointTextHeight=9;Facename=ＭＳ ゴシック
DiaJikokuFont=PointTextHeight=9;Facename=ＭＳ ゴシック
DiaRessyaFont=PointTextHeight=9;Facename=ＭＳ ゴシック
CommentFont=PointTextHeight=9;Facename=ＭＳ ゴシック
DiaMojiColor=00000000
DiaHaikeiColor=00FFFFFF
DiaRessyaColor=00000000
DiaJikuColor=00C0C0C0
EkimeiLength=6
JikokuhyouRessyaWidth=5
.
FileTypeAppComment=OuDia Ver. 1.02.05
"""

let oudData = OuDia.parse(exampleOudText)
print(oudData.rosen.dia[0].kudari.ressya[0].ekiJikoku)
print(oudData.rosen.eki[0].ekimei)
print("---")
print(oudData)

let oudText = OuDia.stringify(oudData)
print("---")
print(oudText)

class OuDia {
    static func parse(_ text: String) -> OudData {
        
        var kudariRessya: [[Ressya]] = [[Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "")]]
        var noboriRessya: [[Ressya]] = [[Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "")]]
        
        var isKudari: Bool = false //どの構成要素を処理しているか示すBool
        var isNobori: Bool = false
        var isRessya: Bool = false
        
        var diaCount: Int = 0 //Dia.の数を数える
        
        var kudariTarget: Int = 0 //配列内の編集すべきインデックスを示す
        var noboriTarget: Int = 0
        
        for lineRow in text.components(separatedBy: .newlines) { //textを1行づつ処理
            let line: String = lineRow.trimmingCharacters(in: .whitespaces) //行の端にある空白を削除
            if line == "" {
                continue
            } else if line == "." { //行がピリオドの場合
                if isRessya {
                    isRessya = false
                } else {
                    if isKudari {
                        isKudari = false
                    }
                    if isNobori {
                        isNobori = false
                    }
                }
            } else if line.hasSuffix(".") { //行がピリオドで終わっている場合
                let type: String = String(line.dropLast())
                switch type {
                case "Dia":
                    diaCount += 1 //typeがDia.である場合を数える
                    kudariRessya.append([Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "")]) //空の要素をひとつ追加
                    noboriRessya.append([Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "")])
                    kudariTarget = (kudariRessya.endIndex-1)-1
                    noboriTarget = (noboriRessya.endIndex-1)-1
                case "Kudari":
                    isKudari = true //Kudari.の処理中であることを示すBool
                case "Nobori":
                    isNobori = true
                case "Ressya":
                    isRessya = true
                    if isKudari {
                        kudariRessya[kudariTarget].append(Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "")) //空の要素をひとつ追加
                    }
                    if isNobori {
                        noboriRessya[noboriTarget].append(Ressya(houkou: "", syubetsu: "", ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: ""))
                    }
                default:
                    break
                }
            } else if line.contains("=") { // 行にイコールが含まれている場合
                var keyAndValue: [String] = line.components(separatedBy: "=")
                let key: String = keyAndValue.removeFirst() //イコールの左側
                let value: String = keyAndValue.joined(separator: "=") //イコールの右側
                let kudariRessyaCount: Int = (kudariRessya[kudariTarget].endIndex-1)-1 //配列内の編集すべきインデックスを示す
                let noboriRessyaCount: Int = (noboriRessya[noboriTarget].endIndex-1)-1
                switch key {
                case "Houkou":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].houkou = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].houkou = value
                    }
                case "Syubetsu":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].syubetsu = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].syubetsu = value
                    }
                case "Ressyabangou":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].ressyabangou = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].ressyabangou = value
                    }
                case "Ressyamei":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].ressyamei = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].ressyamei = value
                    }
                case "Gousuu":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].gousuu = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].gousuu = value
                    }
                case "EkiJikoku":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].ekiJikoku = EkiJikoku.parse(value) //String -> [String]に変換して代入
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].ekiJikoku = EkiJikoku.parse(value)
                    }
                case "Bikou":
                    if isKudari {
                        kudariRessya[kudariTarget][kudariRessyaCount].bikou = value
                    }
                    if isNobori {
                        noboriRessya[noboriTarget][noboriRessyaCount].bikou = value
                    }
                default:
                    break
                }
            }
        }
        kudariRessya.removeLast() //余分な空の要素を削除
        noboriRessya.removeLast()
        for i in 0..<kudariRessya.count {
            kudariRessya[i].removeLast() //余分な空の要素を削除
        }
        for i in 0..<noboriRessya.count {
            noboriRessya[i].removeLast()
        }
        
        var kudari: [Kudari] = []
        var nobori: [Nobori] = []
        
        for i in 0..<diaCount { //Dia.の数だけ配列の要素が増える
            kudari.append(Kudari(ressya: kudariRessya[i]))
        }
        for i in 0..<diaCount {
            nobori.append(Nobori(ressya: noboriRessya[i]))
        }
        
        var dia: [Dia] = []
        
        for i in 0..<diaCount {
            dia.append(Dia(diaName: "", kudari: kudari[i], nobori: nobori[i]))
        }
        
        var ressyasyubetsu: [Ressyasyubetsu] = [Ressyasyubetsu(syubetsumei: "", ryakusyou: "", jikokuhyouMojiColor: "", jikokuhyouFontIndex: "", diagramSenColor: "", diagramSenStyle: "", diagramSenIsBold: "", stopMarkDrawType: "")]
        var eki: [Eki] = [Eki(ekimei: "", ekijikokukeisiki: "", ekikibo: "", kyoukaisen: "", diagramRessyajouhouHyoujiKudari: "", diagramRessyajouhouHyoujiNobori: "")]
        
        var diaTarget: Int = 0 //配列内の編集すべきインデックスを示す
        
        for lineRow in text.components(separatedBy: .newlines) {
            let line: String = lineRow.trimmingCharacters(in: .whitespaces)
            if line == "" {
                continue
            } else if line.hasSuffix(".") {
                let type: String = String(line.dropLast())
                switch type {
                case "Eki":
                    eki.append(Eki(ekimei: "", ekijikokukeisiki: "", ekikibo: "", kyoukaisen: "", diagramRessyajouhouHyoujiKudari: "", diagramRessyajouhouHyoujiNobori: ""))
                case "Ressyasyubetsu":
                    ressyasyubetsu.append(Ressyasyubetsu(syubetsumei: "", ryakusyou: "", jikokuhyouMojiColor: "", jikokuhyouFontIndex: "", diagramSenColor: "", diagramSenStyle: "", diagramSenIsBold: "", stopMarkDrawType: ""))
                case "Dia":
                    break
                default:
                    break
                }
            } else if line.contains("=") {
                var keyAndValue: [String] = line.components(separatedBy: "=")
                let key: String = keyAndValue.removeFirst()
                let value: String = keyAndValue.joined(separator: "=")
                let ekiTarget: Int = (eki.endIndex-1)-1 //配列内の編集すべきインデックスを示す
                let ressyasyubetsuTarget: Int = (ressyasyubetsu.endIndex-1)-1
                switch key {
                case "Ekimei":
                    eki[ekiTarget].ekimei = value
                case "Ekijikokukeisiki":
                    eki[ekiTarget].ekijikokukeisiki = value
                case "Ekikibo":
                    eki[ekiTarget].ekikibo = value
                case "Kyoukaisen":
                    eki[ekiTarget].kyoukaisen = value
                case "DiagramRessyajouhouHyoujiKudari":
                    eki[ekiTarget].diagramRessyajouhouHyoujiKudari = value
                case "DiagramRessyajouhouHyoujiNobori":
                    eki[ekiTarget].diagramRessyajouhouHyoujiNobori = value
                case "Syubetsumei":
                    ressyasyubetsu[ressyasyubetsuTarget].syubetsumei = value
                case "Ryakusyou":
                    ressyasyubetsu[ressyasyubetsuTarget].ryakusyou = value
                case "JikokuhyouMojiColor":
                    ressyasyubetsu[ressyasyubetsuTarget].jikokuhyouMojiColor = value
                case "JikokuhyouFontIndex":
                    ressyasyubetsu[ressyasyubetsuTarget].jikokuhyouFontIndex = value
                case "DiagramSenColor":
                    ressyasyubetsu[ressyasyubetsuTarget].diagramSenColor = value
                case "DiagramSenStyle":
                    ressyasyubetsu[ressyasyubetsuTarget].diagramSenStyle = value
                case "DiagramSenIsBold":
                    ressyasyubetsu[ressyasyubetsuTarget].diagramSenIsBold = value
                case "StopMarkDrawType":
                    ressyasyubetsu[ressyasyubetsuTarget].stopMarkDrawType = value
                case "DiaName":
                    dia[diaTarget].diaName = value
                    diaTarget += 1 //DiaName=〇〇の回数を数えるInt
                default:
                    break
                }
            }
        }
        eki.removeLast() //余分な空の要素を削除
        ressyasyubetsu.removeLast()
        //kudariressyaやnoboriressya, diaの配列はもともと空だったため、removeLast()で余分な要素を取り除く必要はない
        
        var dispProp: DispProp = DispProp(jikokuhyouFont: [], jikokuhyouVFont: "", diaEkimeiFont: "", diaJikokuFont: "", diaRessyaFont: "", commentFont: "", diaMojiColor: "", diaHaikeiColor: "", diaRessyaColor: "", diaJikuColor: "", ekimeiLength: "", jikokuhyouRessyaWidth: "")
        var rosen: Rosen = Rosen(rosenmei: "", eki: eki, ressyasyubetsu: ressyasyubetsu, dia: dia, kitenJikoku: "", diagramDgrYZahyouKyoriDefault: "", comment: "")
        
        for lineRow in text.components(separatedBy: .newlines) {
            let line: String = lineRow.trimmingCharacters(in: .whitespaces)
            if line == "" {
                continue
            } else if line.contains("=") {
                var keyAndValue: [String] = line.components(separatedBy: "=")
                let key: String = keyAndValue.removeFirst()
                let value: String = keyAndValue.joined(separator: "=")
                switch key {
                case "Rosenmei":
                    rosen.rosenmei = value
                case "KitenJikoku":
                    rosen.kitenJikoku = value
                case "DiagramDgrYZahyouKyoriDefault":
                    rosen.diagramDgrYZahyouKyoriDefault = value
                case "Comment":
                    rosen.comment = value
                case "JikokuhyouFont":
                    dispProp.jikokuhyouFont.append(value) //この要素は配列で定義されているのでappend()を用いる
                case "JikokuhyouVFont":
                    dispProp.jikokuhyouVFont = value
                case "DiaEkimeiFont":
                    dispProp.diaEkimeiFont = value
                case "DiaJikokuFont":
                    dispProp.diaJikokuFont = value
                case "DiaRessyaFont":
                    dispProp.diaRessyaFont = value
                case "CommentFont":
                    dispProp.commentFont = value
                case "DiaMojiColor":
                    dispProp.diaMojiColor = value
                case "DiaHaikeiColor":
                    dispProp.diaHaikeiColor = value
                case "DiaRessyaColor":
                    dispProp.diaRessyaColor = value
                case "DiaJikuColor":
                    dispProp.diaJikuColor = value
                case "EkimeiLength":
                    dispProp.ekimeiLength = value
                case "JikokuhyouRessyaWidth":
                    dispProp.jikokuhyouRessyaWidth = value
                default:
                    break
                }
            }
        }
        
        var oudData: OudData = OudData(fileType: "", rosen: rosen, dispProp: dispProp, fileTypeAppComment: "")
        
        for lineRow in text.components(separatedBy: .newlines) {
            let line: String = lineRow.trimmingCharacters(in: .whitespaces)
            if line == "" {
                continue
            } else if line.contains("=") {
                var keyAndValue: [String] = line.components(separatedBy: "=")
                let key: String = keyAndValue.removeFirst()
                let value: String = keyAndValue.joined(separator: "=")
                switch key {
                case "FileType":
                    oudData.fileType = value
                case "FileTypeAppComment":
                    oudData.fileTypeAppComment = value //ここは各Appが名付ける要素
                default:
                    break
                }
            }
        }
        
        return oudData
    }
    
    static func stringify(_ data: OudData) -> String {
        var result: String = ""
        result.append("FileType=\(data.fileType)\n") //OudDataの情報を順番に追加していく
        result.append("Rosen.\n")
        result.append("Rosenmei=\(data.rosen.rosenmei)\n")
        for i in 0..<data.rosen.eki.count {
            result.append("Eki.\n")
            result.append("Ekimei=\(data.rosen.eki[i].ekimei)\n")
            result.append("Ekijikokukeisiki=\(data.rosen.eki[i].ekijikokukeisiki)\n")
            result.append("Ekikibo=\(data.rosen.eki[i].ekikibo)\n")
            if !data.rosen.eki[i].kyoukaisen.isEmpty {
                result.append("Kyoukaisen=\(data.rosen.eki[i].kyoukaisen)\n")
            }
            if !data.rosen.eki[i].diagramRessyajouhouHyoujiKudari.isEmpty {
                result.append("DiagramRessyajouhouHyoujiKudari=\(data.rosen.eki[i].diagramRessyajouhouHyoujiKudari)\n")
            }
            if !data.rosen.eki[i].diagramRessyajouhouHyoujiNobori.isEmpty {
                result.append("DiagramRessyajouhouHyoujiNobori=\(data.rosen.eki[i].diagramRessyajouhouHyoujiNobori)\n")
            }
            result.append(".\n") //Eki. End
        }
        for i in 0..<data.rosen.ressyasyubetsu.count {
            result.append("Ressyasyubetsu.\n")
            result.append("Syubetsumei=\(data.rosen.ressyasyubetsu[i].syubetsumei)\n")
            result.append("Ryakusyou=\(data.rosen.ressyasyubetsu[i].ryakusyou)\n")
            result.append("JikokuhyouMojiColor=\(data.rosen.ressyasyubetsu[i].jikokuhyouMojiColor)\n")
            result.append("JikokuhyouFontIndex=\(data.rosen.ressyasyubetsu[i].jikokuhyouFontIndex)\n")
            result.append("DiagramSenColor=\(data.rosen.ressyasyubetsu[i].diagramSenColor)\n")
            result.append("DiagramSenStyle=\(data.rosen.ressyasyubetsu[i].diagramSenStyle)\n")
            if !data.rosen.ressyasyubetsu[i].diagramSenIsBold.isEmpty {
                result.append("DiagramSenIsBold=\(data.rosen.ressyasyubetsu[i].diagramSenIsBold)\n")
            }
            if !data.rosen.ressyasyubetsu[i].stopMarkDrawType.isEmpty {
                result.append("StopMarkDrawType=\(data.rosen.ressyasyubetsu[i].stopMarkDrawType)\n")
            }
            result.append(".\n") //Ressyasyubetsu. End
        }
        for i in 0..<data.rosen.dia.count {
            result.append("Dia.\n")
            result.append("DiaName=\(data.rosen.dia[i].diaName)\n")
            result.append("Kudari.\n")
            for j in 0..<data.rosen.dia[i].kudari.ressya.count {
                result.append("Ressya.\n")
                result.append("Houkou=\(data.rosen.dia[i].kudari.ressya[j].houkou)\n")
                result.append("Syubetsu=\(data.rosen.dia[i].kudari.ressya[j].syubetsu)\n")
                if !data.rosen.dia[i].kudari.ressya[j].ressyabangou.isEmpty {
                    result.append("Ressyabangou=\(data.rosen.dia[i].kudari.ressya[j].ressyabangou)\n")
                }
                if !data.rosen.dia[i].kudari.ressya[j].ressyamei.isEmpty {
                    result.append("Ressyamei=\(data.rosen.dia[i].kudari.ressya[j].ressyamei)\n")
                }
                if !data.rosen.dia[i].kudari.ressya[j].gousuu.isEmpty {
                    result.append("Gousuu=\(data.rosen.dia[i].kudari.ressya[j].gousuu)\n")
                }
                result.append("EkiJikoku=\(EkiJikoku.stringify(data.rosen.dia[i].kudari.ressya[j].ekiJikoku))\n") //[String] -> Stringに変換して代入
                if !data.rosen.dia[i].kudari.ressya[j].bikou.isEmpty {
                    result.append("Bikou=\(data.rosen.dia[i].kudari.ressya[j].bikou)\n")
                }
                result.append(".\n") //Ressya. End
            }
            result.append(".\n") //Kudari. End
            result.append("Nobori.\n")
            for j in 0..<data.rosen.dia[i].nobori.ressya.count {
                result.append("Ressya.\n")
                result.append("Houkou=\(data.rosen.dia[i].nobori.ressya[j].houkou)\n")
                result.append("Syubetsu=\(data.rosen.dia[i].nobori.ressya[j].syubetsu)\n")
                if !data.rosen.dia[i].nobori.ressya[j].ressyabangou.isEmpty {
                    result.append("Ressyabangou=\(data.rosen.dia[i].nobori.ressya[j].ressyabangou)\n")
                }
                if !data.rosen.dia[i].nobori.ressya[j].ressyamei.isEmpty {
                    result.append("Ressyamei=\(data.rosen.dia[i].nobori.ressya[j].ressyamei)\n")
                }
                if !data.rosen.dia[i].nobori.ressya[j].gousuu.isEmpty {
                    result.append("Gousuu=\(data.rosen.dia[i].nobori.ressya[j].gousuu)\n")
                }
                result.append("EkiJikoku=\(EkiJikoku.stringify(data.rosen.dia[i].nobori.ressya[j].ekiJikoku))\n") //[String] -> Stringに変換して代入
                if !data.rosen.dia[i].nobori.ressya[j].bikou.isEmpty {
                    result.append("Bikou=\(data.rosen.dia[i].nobori.ressya[j].bikou)\n")
                }
                result.append(".\n") //Ressya. End
            }
            result.append(".\n") //Nobori. End
            result.append(".\n") //Dia. End
        }
        result.append("KitenJikoku=\(data.rosen.kitenJikoku)\n")
        result.append("DiagramDgrYZahyouKyoriDefault=\(data.rosen.diagramDgrYZahyouKyoriDefault)\n")
        result.append("Comment=\(data.rosen.comment)\n")
        result.append(".\n") //Rosen End
        result.append("DispProp.\n")
        for i in 0..<data.dispProp.jikokuhyouFont.count {
            result.append("JikokuhyouFont=\(data.dispProp.jikokuhyouFont[i])\n")
        }
        result.append("JikokuhyouVFont=\(data.dispProp.jikokuhyouVFont)\n")
        result.append("DiaEkimeiFont=\(data.dispProp.diaEkimeiFont)\n")
        result.append("DiaJikokuFont=\(data.dispProp.diaJikokuFont)\n")
        result.append("DiaRessyaFont=\(data.dispProp.diaRessyaFont)\n")
        result.append("CommentFont=\(data.dispProp.commentFont)\n")
        result.append("DiaMojiColor=\(data.dispProp.diaMojiColor)\n")
        result.append("DiaHaikeiColor=\(data.dispProp.diaHaikeiColor)\n")
        result.append("DiaRessyaColor=\(data.dispProp.diaRessyaColor)\n")
        result.append("DiaJikuColor=\(data.dispProp.diaJikuColor)\n")
        result.append("EkimeiLength=\(data.dispProp.ekimeiLength)\n")
        result.append("JikokuhyouRessyaWidth=\(data.dispProp.jikokuhyouRessyaWidth)\n")
        result.append(".\n") //DispProp End
        result.append("FileTypeAppComment=" + "Diagram Editor Ver. Aplha 1.0.0" + "\n") //ここは各Appが名付ける要素
        
        return result
    }
}

class EkiJikoku {
    static func parse(_ text: String) -> Array<String> {
        var result: Array<String> = []
        result = text.components(separatedBy: ",")
        return result
    }
    
    static func stringify(_ array: Array<String>) -> String {
        var result: String = ""
        for i in 0 ..< array.count {
            result += array[i] + ","
        }
        result.removeLast()
        return result
    }
}

//ここから下はオブジェクトの定義

struct OudData {
    var fileType: String
    let rosen: Rosen
    let dispProp: DispProp
    var fileTypeAppComment: String
}

struct DispProp { //インデント数: 1
    var jikokuhyouFont: [String]
    var jikokuhyouVFont: String
    var diaEkimeiFont: String
    var diaJikokuFont: String
    var diaRessyaFont: String
    var commentFont: String
    var diaMojiColor: String
    var diaHaikeiColor: String
    var diaRessyaColor: String
    var diaJikuColor: String
    var ekimeiLength: String
    var jikokuhyouRessyaWidth: String
}

struct Rosen { //インデント数: 1
    var rosenmei: String
    let eki: [Eki]
    let ressyasyubetsu: [Ressyasyubetsu]
    let dia: [Dia]
    var kitenJikoku: String
    var diagramDgrYZahyouKyoriDefault: String
    var comment: String
}

struct Dia { //インデント数: 2
    var diaName: String
    let kudari: Kudari
    let nobori: Nobori
}

struct Ressyasyubetsu { //インデント数: 2
    var syubetsumei: String
    var ryakusyou: String
    var jikokuhyouMojiColor: String
    var jikokuhyouFontIndex: String
    var diagramSenColor: String
    var diagramSenStyle: String
    var diagramSenIsBold: String //任意
    var stopMarkDrawType: String //任意
}

struct Eki { //インデント数: 2
    var ekimei: String
    var ekijikokukeisiki: String
    var ekikibo: String
    var kyoukaisen: String //任意
    var diagramRessyajouhouHyoujiKudari: String //任意
    var diagramRessyajouhouHyoujiNobori: String //任意
}

struct Kudari { //インデント数: 3
    let ressya: [Ressya]
}

struct Nobori { //インデント数: 3
    let ressya: [Ressya]
}

struct Ressya { //インデント数: 4
    var houkou: String
    var syubetsu: String
    var ressyabangou: String //任意
    var ressyamei: String //任意
    var gousuu: String //任意
    var ekiJikoku: [String]
    var bikou: String //任意
}
