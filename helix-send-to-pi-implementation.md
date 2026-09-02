# Helix Keybinding Implementation: Send Selection to Pi

**Goal:** Create a Helix keybinding (`<space>c`) that captures the current selection + file metadata and writes to `~/.pi/helix-context`.

## The Solution

Helix supports `%{buffer_name}` in commands to get the current buffer's filename. We pass this directly to our helper script along with the selection via stdin.

## File Format

The keybinding should write `~/.pi/helix-context` in this format:

```
// /path/to/file.ext
<selected code here>
```

Example:
```
// /Users/vincentbenoot/myproject/src/main.rs
fn calculate_result(x: i32) -> i32 {
    let y = x * 2;
    return y + 1;
}
```

## Implementation Steps

### Step 1: Create the helper script

Create file `~/.local/bin/helix-send-to-pi.sh`:

```bash
#!/bin/bash
# Usage: piped-selection | helix-send-to-pi.sh <filename>
# Writes selection + filename metadata to ~/.pi/helix-context

FILENAME="$1"
OUTPUT_FILE="$HOME/.pi/helix-context"

# Read selection from stdin
SELECTION=$(cat)

# Write formatted output
{
    echo "// $FILENAME"
    echo "$SELECTION"
} > "$OUTPUT_FILE"
```

Make it executable:
```bash
chmod +x ~/.local/bin/helix-send-to-pi.sh
```

### Step 2: Add keybinding to Helix config

Edit `~/.config/helix/config.toml` (create if it doesn't exist) and add:

```toml
[keys.normal.space]
c = ":pipe-to ~/.local/bin/helix-send-to-pi.sh %{buffer_name}"
```

That's it! The `%{buffer_name}` variable gets substituted with the current file path automatically.

## Usage Flow

1. In Helix: select code
2. Press `<space>c`
3. Selection + filename are written to `~/.pi/helix-context`
4. In pi: `/hx explain this function`
5. Pi loads and shows the context

## Edge Cases & Notes

- **Empty selection:** Script still runs, writes just the filename. Pi will show minimal context.
- **Unsaved files:** `%{buffer_name}` still gives the filename (even if not yet saved to disk)

## Testing

1. Create test file: `echo "fn test() { println!(\"hello\"); }" > /tmp/test.rs`
2. Open in Helix: `hx /tmp/test.rs`
3. Select the function body
4. Press `<space>c`
5. Verify: `cat ~/.pi/helix-context` shows the selection with filename
