# EFDBUI Authentication Guide

## Issue: efdb Requires Browser Authentication

The `efdb` command requires authentication via a web browser, which can cause the GUI app to hang when it tries to open a browser.

## Solution: Pre-authenticate Before Using the App

### Step 1: Authenticate in Terminal

Before launching the EFDBUI app, you must authenticate `efdb` in your terminal:

```bash
# Run any efdb command to trigger authentication
efdb cluster info <any-cluster-name>
```

This will:
1. Open your browser for authentication
2. Complete the OAuth flow
3. Store authentication credentials
4. Allow subsequent efdb commands to work without browser interaction

### Step 2: Verify Authentication

Test that authentication works without browser interaction:

```bash
# This should run without opening a browser
efdb cluster info <cluster-name>
```

If it runs successfully and shows cluster info, you're authenticated!

### Step 3: Launch the App

Now you can safely launch EFDBUI:

```bash
cd /Users/sramamoorthy/EFDBUI
open .build/EFDBUI.app
```

The app will now work without hanging because efdb is already authenticated.

## How Long Does Authentication Last?

Authentication tokens typically last for:
- **Hours to days** depending on your organization's settings
- If the app starts hanging again, re-authenticate in the terminal

## Troubleshooting

### App Still Hangs

1. **Kill the app:**
   ```bash
   pkill -9 EFDBUI
   ```

2. **Clear any cached credentials:**
   ```bash
   # Check efdb documentation for credential location
   # Usually in ~/.config/efdb or similar
   ```

3. **Re-authenticate in terminal:**
   ```bash
   efdb cluster info <cluster-name>
   ```

4. **Try the app again**

### Authentication Expired

If you get errors about authentication:

1. **Re-authenticate in terminal:**
   ```bash
   efdb cluster info <cluster-name>
   # Complete browser authentication
   ```

2. **The app will work again**

### Timeout Error

The app now has a 30-second timeout. If you see:
```
Command timed out. This may indicate authentication is required.
Please authenticate in your terminal first: 'efdb cluster info <cluster_name>'
```

This means:
- Authentication is required, OR
- The command is taking too long

**Solution:** Authenticate in terminal as described above.

## Technical Details

### What Changed

The app now:
1. **Has a 30-second timeout** - prevents indefinite hanging
2. **Sets environment variables** - tries to prevent browser opening
3. **Provides clear error messages** - tells you if authentication is needed

### Why This Happens

- GUI apps run in a different environment than Terminal
- Browser-based OAuth flows expect terminal interaction
- The app can't complete the browser authentication flow automatically

### Best Practice

**Always authenticate efdb in Terminal before using the GUI app.**

This ensures a smooth experience without hangs or interruptions.

## Quick Reference

```bash
# 1. Authenticate first (only needed once per session)
efdb cluster info <any-cluster-name>

# 2. Launch the app
cd /Users/sramamoorthy/EFDBUI
open .build/EFDBUI.app

# 3. Use the app normally

# If app hangs:
pkill -9 EFDBUI
# Then re-authenticate and try again
```

---

**Remember:** The GUI app assumes you're already authenticated. Always run an efdb command in Terminal first!

