# Pantas Demo Workflow

This document outlines the step-by-step workflow for running the app demonstration, from initial setup to the final showcase of features.

## 1. Preparation (Before Presentation)
1. **Connect Devices:** Ensure both your Mac and your Android test phone are connected to your iPhone's Wi-Fi hotspot.
2. **Launch the App:** Open a terminal window, navigate to the project directory (`cd /Users/aedwon/Documents/Projects/Pantas`), and start the app:
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart
   ```
   *(Note: If you have multiple devices connected, use `flutter devices` to find your ID, then add `-d <device-id>` to the command. Wait for it to compile and launch. Keep this terminal tab ("Terminal 1") open and running).*
3. **Prep the Demo Tools:** Open a **second** terminal window ("Terminal 2") in the exact same directory. This is where you will run your "Hackerman" commands.
4. **Clean Slate:** In Terminal 2, type `./tools/demo reset`. Then, tap **`R`** in Terminal 1. This ensures the app is completely fresh before your audience sees it.

---

## 2. The Live Demo Flow

### Step A: Onboarding
- **Action (On Phone):** Start the app and walk the audience through the clean onboarding flow. 
- **Talking Points:** Show the smooth age gate (birthyear picker) and the exam picker screen. Select an exam and proceed to the main app.

### Step B: Basic Functions & Tabs
- **Action (On Phone):** Navigate through the Home, Study, and Progress tabs.
- **Talking Points:** Show the UI, the design language, and the layout. Note that right now, the progress map and streaks are empty because it's a brand new account.

### Step C: The "Pro" Unlock
- **Action (On Terminal 2):** While showing a locked "Free" screen on the phone, hit enter on:
  ```bash
  ./tools/demo pro
  ```
- **Action (On Phone):** Do absolutely nothing. 
- **Talking Points:** Watch the screen react instantly and unlock the Pro features live without you touching the device or restarting the app.

### Step D: Time Skip (Populating Faux Data)
- **Action (On Terminal 2):** To show what a dedicated student's profile looks like, run:
  ```bash
  ./tools/demo populate
  ```
- **Action (On Terminal 1):** Tap the **`R`** key on your keyboard to Hot Restart the app.
- **Talking Points:** The app will instantly refresh. Show the audience the newly populated Progress tab—complete with fake daily streaks, completed lessons, and recorded quiz attempts to demonstrate how the metrics look when active. *(Note: The script intelligently populates data specifically for the exam you just chose during onboarding).*

### Step E: Switching Exams (Optional)
- **Action (On Phone):** Go to Settings and use the "Change Exam" feature to select a different exam (e.g., UPCAT or Ateneo).
- **Talking Points:** Show how the app dynamically rebuilds the study paths, study materials, and UI structure based on the specific exam syllabus selected.
