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

//使用例
let oudData = OuDia.parse(exampleOudText)
print(oudData)
print("---")
let oudText = OuDia.stringify(oudData)
print(oudText)
print("---")
print(oudData.rosen.dia[0].kudari.ressya[0].ekiJikoku)
print(oudData.rosen.eki[0].ekimei)

class OuDia {
    //MARK: - 文字列→構造体
    static func parse(_ text: String) -> OudData {
        enum ProcessState {
            case none
            case kudari
            case nobori
        }

        //このoudDataプロパティに値が代入、追加されていく
        var oudData = OudData(fileType: "",
                              rosen: Rosen(rosenmei: "",
                                           eki: [],
                                           ressyasyubetsu: [],
                                           dia: [],
                                           kitenJikoku: "",
                                           diagramDgrYZahyouKyoriDefault: "",
                                           comment: ""
                                          ),
                              dispProp: DispProp(jikokuhyouFont: [],
                                                 jikokuhyouVFont: "",
                                                 diaEkimeiFont: "",
                                                 diaJikokuFont: "",
                                                 diaRessyaFont: "",
                                                 commentFont: "",
                                                 diaMojiColor: "",
                                                 diaHaikeiColor: "",
                                                 diaRessyaColor: "",
                                                 diaJikuColor: "",
                                                 ekimeiLength: "",
                                                 jikokuhyouRessyaWidth: ""
                                                ),
                              fileTypeAppComment: ""
        )

        var isRessya = false
        var processingHoukouState: ProcessState = .none //どの構成要素を処理しているかを示す

        for lineRow in text.components(separatedBy: .newlines) { //textを1行づつ処理
            let line: String = lineRow.trimmingCharacters(in: .whitespaces) //行の端にある空白を削除
            if line.isEmpty {
                continue
            } else if line == "." { //行がピリオドの場合
                resetProcessingDiaState()
            } else if line.hasSuffix(".") { //行がピリオドで終わっている場合
                handleScopeEntry(line: line)
            } else if line.contains("=") { // 行にイコールが含まれている場合
                setValueFromKey(line: line)
            }
        }
        return oudData

        func resetProcessingDiaState() {
            if isRessya {
                isRessya = false
            } else {
                processingHoukouState = .none
            }
        }

        func handleScopeEntry(line: String) {
            switch line {
            case "Kudari.":
                processingHoukouState = .kudari //Kudari.の処理中であることを示すBool
            case "Nobori.":
                processingHoukouState = .nobori
            case "Ressya.":
                isRessya = true
                if var diaTarget = oudData.rosen.dia.lastElement {
                    if case .kudari = processingHoukouState {
                        //空の要素をひとつ追加
                        diaTarget.kudari.ressya.append( Ressya(houkou: "", syubetsu: 0, ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "") )
                        oudData.rosen.dia.lastElement = diaTarget
                    }
                    if case .nobori = processingHoukouState {
                        diaTarget.nobori.ressya.append( Ressya(houkou: "", syubetsu: 0, ressyabangou: "", ressyamei: "", gousuu: "", ekiJikoku: [], bikou: "") )
                        oudData.rosen.dia.lastElement = diaTarget
                    }
                }
            case "Eki.":
                oudData.rosen.eki.append( Eki(ekimei: "", ekijikokukeisiki: .hatsu, ekikibo: .ippan, kyoukaisen: "", diagramRessyajouhouHyoujiKudari: "", diagramRessyajouhouHyoujiNobori: "") )
            case "Ressyasyubetsu.":
                oudData.rosen.ressyasyubetsu.append( Ressyasyubetsu(syubetsumei: "", ryakusyou: "", jikokuhyouMojiColor: "", jikokuhyouFontIndex: "", diagramSenColor: "", diagramSenStyle: .jissen, diagramSenIsBold: "", stopMarkDrawType: "") )
            case "Dia.":
                oudData.rosen.dia.append( Dia(diaName: "", kudari: Kudari(ressya: []), nobori: Nobori(ressya: [])) )
            default:
                break
            }
            return
        }

        func setValueFromKey(line: String) {
            var keyAndValue: [String] = line.components(separatedBy: "=")
            let key: String = keyAndValue.removeFirst() //イコールの左側
            let value: String = keyAndValue.joined(separator: "=") //イコールの右側
            updateElement()
            return

            func updateElement() {
                if case .kudari = processingHoukouState, var kudariRessyaTarget = oudData.rosen.dia.lastElement?.kudari.ressya.lastElement {
                    updateRessya(in: &kudariRessyaTarget, withKey: key, value: value)
                    oudData.rosen.dia.lastElement?.kudari.ressya.lastElement = kudariRessyaTarget
                } else if case .nobori = processingHoukouState, var noboriRessyaTarget = oudData.rosen.dia.lastElement?.nobori.ressya.lastElement {
                    updateRessya(in: &noboriRessyaTarget, withKey: key, value: value)
                    oudData.rosen.dia.lastElement?.nobori.ressya.lastElement = noboriRessyaTarget
                }
                if var ekiTarget = oudData.rosen.eki.lastElement {
                    updateEki(in: &ekiTarget, withKey: key, value: value)
                    oudData.rosen.eki.lastElement = ekiTarget
                }
                if var ressyasyubetsuTarget = oudData.rosen.ressyasyubetsu.lastElement {
                    updateRessyasyubetsu(in: &ressyasyubetsuTarget, withKey: key, value: value)
                    oudData.rosen.ressyasyubetsu.lastElement = ressyasyubetsuTarget
                }
                if var diaTarget = oudData.rosen.dia.lastElement {
                    updateDia(in: &diaTarget, withKey: key, value: value)
                    oudData.rosen.dia.lastElement = diaTarget
                }
                updateRosen(key: key, value: value)
                updateDispProp(key: key, value: value)
                updateOudData(key: key, value: value)
                return

                func updateRessya(in ressya: inout Ressya, withKey key: String, value: String) {
                    switch key {
                    case "Houkou":
                        ressya.houkou = value
                    case "Syubetsu":
                        if let valueInt = Int(value) {
                            ressya.syubetsu = valueInt
                        }
                    case "Ressyabangou":
                        ressya.ressyabangou = value
                    case "Ressyamei":
                        ressya.ressyamei = value
                    case "Gousuu":
                        ressya.gousuu = value
                    case "EkiJikoku":
                        ressya.ekiJikoku = EkiJikoku.parse(value) //String -> [String]に変換して代入
                    case "Bikou":
                        ressya.bikou = value
                    default:
                        break
                    }
                }

                func updateEki(in eki: inout Eki, withKey key: String, value: String) {
                    switch key {
                    case "Ekimei":
                        eki.ekimei = value
                    case "Ekijikokukeisiki":
                        switch value {
                        case let jikokukeisiki:
                            eki.ekijikokukeisiki = Ekijikokukeisiki(rawValue: jikokukeisiki) ?? .hatsu
                        }
                    case "Ekikibo":
                        switch value {
                        case let kibo:
                            eki.ekikibo = Ekikibo(rawValue: kibo) ?? .ippan
                        }
                    case "Kyoukaisen":
                        eki.kyoukaisen = value
                    case "DiagramRessyajouhouHyoujiKudari":
                        eki.diagramRessyajouhouHyoujiKudari = value
                    case "DiagramRessyajouhouHyoujiNobori":
                        eki.diagramRessyajouhouHyoujiNobori = value
                    default:
                        break
                    }
                }

                func updateRessyasyubetsu(in ressyasyubetsu: inout Ressyasyubetsu, withKey key: String, value: String) {
                    switch key {
                    case "Syubetsumei":
                        ressyasyubetsu.syubetsumei = value
                    case "Ryakusyou":
                        ressyasyubetsu.ryakusyou = value
                    case "JikokuhyouMojiColor":
                        ressyasyubetsu.jikokuhyouMojiColor = value
                    case "JikokuhyouFontIndex":
                        ressyasyubetsu.jikokuhyouFontIndex = value
                    case "DiagramSenColor":
                        ressyasyubetsu.diagramSenColor = value
                    case "DiagramSenStyle":
                        switch value {
                        case let senStyle:
                            ressyasyubetsu.diagramSenStyle = DiagramSenStyle(rawValue: senStyle) ?? .jissen
                        }
                    case "DiagramSenIsBold":
                        ressyasyubetsu.diagramSenIsBold = value
                    case "StopMarkDrawType":
                        ressyasyubetsu.stopMarkDrawType = value
                    default:
                        break
                    }
                }

                func updateDia(in dia: inout Dia, withKey key: String, value: String) {
                    switch key {
                    case "DiaName":
                        dia.diaName = value
                    default:
                        break
                    }
                }

                func updateRosen(key: String, value: String) {
                    switch key {
                    case "Rosenmei":
                        oudData.rosen.rosenmei = value
                    case "KitenJikoku":
                        oudData.rosen.kitenJikoku = value
                    case "DiagramDgrYZahyouKyoriDefault":
                        oudData.rosen.diagramDgrYZahyouKyoriDefault = value
                    case "Comment":
                        oudData.rosen.comment = value
                    default:
                        break
                    }
                }

                func updateDispProp(key: String, value: String) {
                    switch key {
                    case "JikokuhyouFont":
                        oudData.dispProp.jikokuhyouFont.append(value) //この要素は配列で定義されているのでappend()を用いる
                    case "JikokuhyouVFont":
                        oudData.dispProp.jikokuhyouVFont = value
                    case "DiaEkimeiFont":
                        oudData.dispProp.diaEkimeiFont = value
                    case "DiaJikokuFont":
                        oudData.dispProp.diaJikokuFont = value
                    case "DiaRessyaFont":
                        oudData.dispProp.diaRessyaFont = value
                    case "CommentFont":
                        oudData.dispProp.commentFont = value
                    case "DiaMojiColor":
                        oudData.dispProp.diaMojiColor = value
                    case "DiaHaikeiColor":
                        oudData.dispProp.diaHaikeiColor = value
                    case "DiaRessyaColor":
                        oudData.dispProp.diaRessyaColor = value
                    case "DiaJikuColor":
                        oudData.dispProp.diaJikuColor = value
                    case "EkimeiLength":
                        oudData.dispProp.ekimeiLength = value
                    case "JikokuhyouRessyaWidth":
                        oudData.dispProp.jikokuhyouRessyaWidth = value
                    default:
                        break
                    }
                }

                func updateOudData(key: String, value: String) {
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
        }
    }

    //MARK: - 構造体→文字列
    static func stringify(_ data: OudData) -> String {
        var result: String = ""
        result.append("FileType=\(data.fileType)\n") //OudDataの情報を順番に追加していく
        stringifyRosen(rosen: data.rosen)
        stringifyDispProp(dispProp: data.dispProp)
        result.append("FileTypeAppComment=" + "Diagram Editor Ver. Alpha 1.0.0") //ここは各Appが名付ける要素
        return result

        func stringifyRosen(rosen: Rosen) {
            result.append("Rosen.\n")
            result.append("Rosenmei=\(rosen.rosenmei)\n")
            stringifyEki(ekiArr: rosen.eki)
            stringifyRessyasyubetsu(ressyasyubetsuArr: rosen.ressyasyubetsu)
            stringifyDia(diaArr: rosen.dia)
            result.append("KitenJikoku=\(rosen.kitenJikoku)\n")
            result.append("DiagramDgrYZahyouKyoriDefault=\(rosen.diagramDgrYZahyouKyoriDefault)\n")
            result.append("Comment=\(rosen.comment)\n")
            result.append(".\n") //Rosen End
            return

            func stringifyEki(ekiArr: [Eki]) {
                for eki in ekiArr {
                    result.append("Eki.\n")
                    result.append("Ekimei=\(eki.ekimei)\n")
                    result.append("Ekijikokukeisiki=\(eki.ekijikokukeisiki.rawValue)\n")
                    result.append("Ekikibo=\(eki.ekikibo.rawValue)\n")
                    if !eki.kyoukaisen.isEmpty {
                        result.append("Kyoukaisen=\(eki.kyoukaisen)\n")
                    }
                    if !eki.diagramRessyajouhouHyoujiKudari.isEmpty {
                        result.append("DiagramRessyajouhouHyoujiKudari=\(eki.diagramRessyajouhouHyoujiKudari)\n")
                    }
                    if !eki.diagramRessyajouhouHyoujiNobori.isEmpty {
                        result.append("DiagramRessyajouhouHyoujiNobori=\(eki.diagramRessyajouhouHyoujiNobori)\n")
                    }
                    result.append(".\n") //Eki. End
                }
                return
            }

            func stringifyRessyasyubetsu(ressyasyubetsuArr: [Ressyasyubetsu]) {
                for ressyasyubetsu in ressyasyubetsuArr {
                    result.append("Ressyasyubetsu.\n")
                    result.append("Syubetsumei=\(ressyasyubetsu.syubetsumei)\n")
                    result.append("Ryakusyou=\(ressyasyubetsu.ryakusyou)\n")
                    result.append("JikokuhyouMojiColor=\(ressyasyubetsu.jikokuhyouMojiColor)\n")
                    result.append("JikokuhyouFontIndex=\(ressyasyubetsu.jikokuhyouFontIndex)\n")
                    result.append("DiagramSenColor=\(ressyasyubetsu.diagramSenColor)\n")
                    result.append("DiagramSenStyle=\(ressyasyubetsu.diagramSenStyle.rawValue)\n")
                    if !ressyasyubetsu.diagramSenIsBold.isEmpty {
                        result.append("DiagramSenIsBold=\(ressyasyubetsu.diagramSenIsBold)\n")
                    }
                    if !ressyasyubetsu.stopMarkDrawType.isEmpty {
                        result.append("StopMarkDrawType=\(ressyasyubetsu.stopMarkDrawType)\n")
                    }
                    result.append(".\n") //Ressyasyubetsu. End
                }
                return
            }

            func stringifyDia(diaArr: [Dia]) {
                for dia in diaArr {
                    result.append("Dia.\n")
                    result.append("DiaName=\(dia.diaName)\n")
                    result.append("Kudari.\n")
                    stringifyRessya(ressyaArr: dia.kudari.ressya)
                    result.append(".\n") //Kudari. End
                    result.append("Nobori.\n")
                    stringifyRessya(ressyaArr: dia.nobori.ressya)
                    result.append(".\n") //Nobori. End
                    result.append(".\n") //Dia. End
                }
                return

                func stringifyRessya(ressyaArr: [Ressya]) {
                    for ressya in ressyaArr {
                        result.append("Ressya.\n")
                        if !ressya.houkou.isEmpty {
                            result.append("Houkou=\(ressya.houkou)\n")
                            result.append("Syubetsu=\(ressya.syubetsu)\n")
                        }
                        if !ressya.ressyabangou.isEmpty {
                            result.append("Ressyabangou=\(ressya.ressyabangou)\n")
                        }
                        if !ressya.ressyamei.isEmpty {
                            result.append("Ressyamei=\(ressya.ressyamei)\n")
                        }
                        if !ressya.gousuu.isEmpty {
                            result.append("Gousuu=\(ressya.gousuu)\n")
                        }
                        if !ressya.ekiJikoku.isEmpty {
                            result.append("EkiJikoku=\( EkiJikoku.stringify(ressya.ekiJikoku) )\n")
                        }
                        if !ressya.bikou.isEmpty {
                            result.append("Bikou=\(ressya.bikou)\n")
                        }
                        result.append(".\n") //Ressya. End
                    }
                    return
                }
            }
        }

        func stringifyDispProp(dispProp: DispProp) {
            result.append("DispProp.\n")
            for jikokuhyouFont in dispProp.jikokuhyouFont {
                result.append("JikokuhyouFont=\(jikokuhyouFont)\n")
            }
            result.append("JikokuhyouVFont=\(dispProp.jikokuhyouVFont)\n")
            result.append("DiaEkimeiFont=\(dispProp.diaEkimeiFont)\n")
            result.append("DiaJikokuFont=\(dispProp.diaJikokuFont)\n")
            result.append("DiaRessyaFont=\(dispProp.diaRessyaFont)\n")
            result.append("CommentFont=\(dispProp.commentFont)\n")
            result.append("DiaMojiColor=\(dispProp.diaMojiColor)\n")
            result.append("DiaHaikeiColor=\(dispProp.diaHaikeiColor)\n")
            result.append("DiaRessyaColor=\(dispProp.diaRessyaColor)\n")
            result.append("DiaJikuColor=\(dispProp.diaJikuColor)\n")
            result.append("EkimeiLength=\(dispProp.ekimeiLength)\n")
            result.append("JikokuhyouRessyaWidth=\(dispProp.jikokuhyouRessyaWidth)\n")
            result.append(".\n") //DispProp End
            return
        }
    }
}

//MARK: - EkiJikokuのパース/文字列化
class EkiJikoku {
    static func parse(_ text: String) -> [String] {
        return text.components(separatedBy: ",")
    }

    static func stringify(_ jikokuArr: [String]) -> String {
        return jikokuArr.joined(separator: ",")
    }
}

//extension
extension Array {
    var lastElement: Element? {
        get {
            return self.last
        }
        set {
            if let newValue = newValue {
                self[self.endIndex - 1] = newValue
            }
        }
    }
}

//MARK: - 構造体の定義
struct OudData: Equatable {
    var fileType: String
    var rosen: Rosen
    var dispProp: DispProp
    var fileTypeAppComment: String
}

struct Rosen: Equatable { //インデント数: 1
    var rosenmei: String
    var eki: [Eki]
    var ressyasyubetsu: [Ressyasyubetsu]
    var dia: [Dia]
    var kitenJikoku: String
    var diagramDgrYZahyouKyoriDefault: String
    var comment: String
}

struct DispProp: Equatable { //インデント数: 1
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

struct Eki: Hashable, Equatable { //インデント数: 2
    var ekimei: String
    var ekijikokukeisiki: Ekijikokukeisiki
    var ekikibo: Ekikibo
    var kyoukaisen: String //任意
    var diagramRessyajouhouHyoujiKudari: String //任意
    var diagramRessyajouhouHyoujiNobori: String //任意
}

struct Ressyasyubetsu: Equatable { //インデント数: 2
    var syubetsumei: String
    var ryakusyou: String
    var jikokuhyouMojiColor: String
    var jikokuhyouFontIndex: String
    var diagramSenColor: String
    var diagramSenStyle: DiagramSenStyle
    var diagramSenIsBold: String //任意
    var stopMarkDrawType: String //任意
}

struct Dia: Equatable { //インデント数: 2
    var diaName: String
    var kudari: Kudari
    var nobori: Nobori
}

struct Kudari: Equatable { //インデント数: 3
    var ressya: [Ressya]
}

struct Nobori: Equatable { //インデント数: 3
    var ressya: [Ressya]
}

struct Ressya: Hashable, Equatable { //インデント数: 4
    var houkou: String
    var syubetsu: Int
    var ressyabangou: String //任意
    var ressyamei: String //任意
    var gousuu: String //任意
    var ekiJikoku: [String]
    var bikou: String //任意
}

//MARK: - enum
enum Ekijikokukeisiki: String {
    case hatsu = "Jikokukeisiki_Hatsu"
    case hatsuchaku = "Jikokukeisiki_Hatsuchaku"
    case kudariChaku = "Jikokukeisiki_KudariChaku"
    case noboriChaku = "Jikokukeisiki_NoboriChaku"
}

enum Ekikibo: String {
    case ippan = "Ekikibo_Ippan"
    case syuyou = "Ekikibo_Syuyou"
}

enum DiagramSenStyle: String {
    case jissen = "SenStyle_Jissen"
    case hasen = "SenStyle_Hasen"
    case tensen = "SenStyle_Tensen"
    case ittensasen = "SenStyle_Ittensasen"
}
