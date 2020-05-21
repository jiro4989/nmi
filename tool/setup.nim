import strutils, os, strformat, times, parseopt

const
  doc = """
setup setups this template repository.

Usage:
    setup [options]
    setup (-h | --help)
    setup --author:<author> --appname:<application_name>

Options:
    -h, --help                      Print this help
    --author:<author>               Set author name
    --appname:<application_name>    Set application name
  """

proc changeFile(beforeFile, afterFile, appName, author, dt: string) =
  let body =
    readFile(beforeFile)
      .replace("APPNAME", appName)
      .replace("<author>", author)
      .replace("<date>", dt)
  writeFile(beforeFile, body)
  echo &"{beforeFile} was replaced."

  if afterFile == "": return
  moveFile(beforeFile, afterFile)
  echo &"{beforeFile} was renamed {afterFile}."

var
  optParser = initOptParser(commandLineParams())
  author = ""
  appName = ""

for kind, key, val in optParser.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      echo doc
      quit 0
    of "author":
      author = val
    of "appname":
      appName = val
  of cmdEnd:
    assert false # cannot happen
  else: discard

if author == "" or appName == "":
  stderr.writeLine "'author' and 'appname' must be set."
  stderr.writeLine "see 'setup -h'."
  quit 1

let
  now = now().format("yyyy")

changeFile("APPNAME.nimble", &"{appName}.nimble", appName, author, now)
changeFile("README.rst", "", appName, author, now)
changeFile("src"/"APPNAME.nim", "src" / &"{appName}.nim", appName, author, now)
changeFile("tests"/"test1.nim", "", appName, author, now)
changeFile("LICENSE", "", appName, author, now)
changeFile(".github" / "workflows" / "main.yml", "", appName, author, now)

echo ""
echo "success."
