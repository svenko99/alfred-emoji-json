

# Alfred Emoji JSON

A lightweight command-line tool that enables workflow authors to use a custom `"icon"` with `"type": "emoji"` in [Alfred Script Filter JSON](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/). Simply [pipe](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html) the JSON output from your program into the tool (`alfred-emoji-json`). The tool converts the emoji into a PNG file so that it can be displayed as the item’s icon.


## Details

- Emoji should be placed in the `"path"` field of the `"icon"` object with `"type": "emoji`. 
- Emojis are converted into 256px transparent PNG files stored in `./emojis/`.
- The `./emojis` directory is created automatically in workflow folder if it does not exist.
- PNG files are reused if already generated, speeding up repeated runs.

## Raw JSON example 

Here is an example of the raw JSON that you might generate from your program:

```json
{
  "items": [
    {
      "title": "Build Project",
      "subtitle": "Build succeeded",
      "arg": "build",
      "icon": {
        "type": "emoji",
        "path": "🟢"
      }
    },
    {
      "title": "Run Tests",
      "subtitle": "Tests failed",
      "arg": "test",
      "icon": {
        "type": "emoji",
        "path": "🔴"
      }
    }
  ]
}
```

Pipe the JSON through the tool:

```bash
cat tasks.json | ./alfred-emoji-json
```

<img src="assets/demo1.png" alt="demo picture 1" width="80%" height="auto">

## Code example

Consider the following Python code, which generates Alfred Script Filter JSON with emoji icons based on task scores:

```python
#!/usr/bin/env python3
import json

# Simple list of (task, score) tuples
tasks = [
    ("Morning Workout", 5),
    ("Emails", 3),
    ("Report Writing", 2),
    ("Late Meeting", 0)
]

# Map scores to emojis
emojis = ["😭", "😢", "🙁", "😐", "🙂", "😄"]

items = []
for task, score in tasks:
    item = {
        "title": task,
        "subtitle": f"Score: {score}",
        "arg": task,
        "icon": {"type": "emoji", "path": emojis[score]}
    }
    items.append(item)

output = {"items": items}
print(json.dumps(output, ensure_ascii=False, indent=2))
```

Pipe the output into the tool to automatically convert the emojis into PNG icons:

```bash
./example.py | ./alfred-emoji-json
```

<img src="assets/demo2.png" alt="demo picture 1" width="80%" height="auto">

## Installation

There are two ways to install `alfred-emoji-json`:

#### 1. Build from source

If you have Swift installed, you can build the tool from source:

```bash
git clone https://github.com/svenko99/alfred-emoji-json.git
cd alfred-emoji-json
swiftc src/alfred-emoji-json.swift -o alfred-emoji-json
```
This will produce an executable `alfred-emoji-json` in the current folder. 

#### 2. Use unsigned binary

You can also download the prebuilt unsigned binary. If macOS blocks the execution due to security settings run: `sudo xattr -rd com.apple.quarantine ./alfred-emoji-json`.


After obtaining the executable (either by building from source or downloading the unsigned binary), you can integrate it into your Alfred workflow by moving the executable into your workflow folder.
