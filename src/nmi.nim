import strformat, strutils, parseopt, os, terminal

type
  Options = ref object
    args: seq[string]
    useHelp, useVersion, color: bool

const
  nimAscii = """
                                                               
                              :::                              
            :               ::::::               ::            
           ::::      ::::::::::::::::::::.     ::::            
          ::::::::::::::::::::::::::::::::::::::::::           
         ::::::::::::::::::::::::::::::::::::::::::::          
       :::::::::::::::::::::::::::::::::::::::::::::::::       
 ::. ::::::::::::::::::::            ::::::::::::::::::::: ::  
  :::::::::::::::::                         :::::::::::::::::  
  :::::::::::::                                :::::::::::::   
  :::::::::::                                     ::::::::::   
   ::::::::                                         ::::::::   
   ::::::                                            ::::::    
    ::::                                              ::::.    
    *::.                                               :::     
     %@@                                               @%%     
      @@@                     @@                     #@@@      
      @@@@                 #@@@@@@@                 @@@@       
       @@@@#            =@@@@@@@@@@@@@             @@@@@       
       @@@@@@@%       @@@@@@@@@@@@@@@@@@@       @@@@@@@        
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        
        *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         
         *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          
           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           
            +@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@               
                 +@@@@@@@@@@@@@@@@@@@@@@@@@@@                  
                     +@@@@@@@@@@@@@@@@@@@                      
                             +@@@                              
"""
  appName = "nmi"
  version = &"""{appName} command version 1.1.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/nmi"""
  doc = &"""
{appName} display animations aimed to correct users who accidentally enter nmi instead of nim.

Usage:
    {appName} [options]
    {appName} (-h | --help)
    {appName} (-v | --version)

Options:
    -h, --help                       Print this help
    -v, --version                    Print version
    -c, --color                      Colorful print
"""

proc getCmdOpts(params: seq[string]): Options =
  ## コマンドライン引数を解析して返す。
  ## helpとversionが見つかったらテキストを標準出力して早期リターンする。
  var optParser = initOptParser(params)
  new result

  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      result.args.add(key)
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo doc
        result.useHelp = true
        return
      of "version", "v":
        echo version
        result.useVersion = true
        return
      of "color", "c":
        result.color = true
    of cmdEnd:
      assert false # cannot happen

proc colorful(text: string): string =
  let yellow = ":."
  let black = "@%#*+="
  result = text
  result = result.replace(" ", &"\x1b[47m \x1b[0m")
  for c in yellow:
    result = result.replace($c, &"\x1b[43m \x1b[0m")
  for c in black:
    result = result.replace($c, &"\x1b[40m \x1b[0m")

proc traverse(text: string, color: bool) =
  let width = terminalWidth() - 5
  let asciiHeight = text.split("\n").len
  let lines = text.split("\n")
  var i: int
  for leftPadWidth in countdown(width, 0):
    var buf: seq[string]
    for line in lines:
      if line.len < 1: continue
      let leftPad = " ".repeat(leftPadWidth)
      if line.len <= i: i = line.len - 1
      let logoPart = line[0..i]
      buf.add(leftPad & logoPart)

    var t = buf.join("\n")
    if color:
      t = t.colorful
    echo t

    cursorUp(asciiHeight - 1)
    sleep 50
    inc i

  for x in 0..lines[0].len:
    var buf: seq[string]
    for line in lines:
      if line.len < 1: continue
      buf.add(line[x..^1])

    var t = buf.join("\n")
    if color:
      t = t.colorful
    echo t

    cursorUp(asciiHeight - 1)
    sleep 50

when isMainModule and not defined modeTest:
  when not defined windows:
    from posix import onSignal, SIGTERM, SIGINT
    onSignal(SIGTERM, SIGINT):
      discard

  let opts = commandLineParams().getCmdOpts()
  if opts.useHelp or opts.useVersion:
    quit 0

  hideCursor()
  eraseScreen()
  setCursorPos(0, 0)
  traverse(nimAscii, opts.color)

  proc closeFunc() {.noconv.} =
    showCursor()
    eraseScreen()
    quit 1

  setControlCHook(closeFunc)

  showCursor()
