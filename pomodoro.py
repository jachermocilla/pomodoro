#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk

class PomodoroTimer:
    def __init__(self, root):
        self.root = root
        self.root.title("Pomodoro")
        self.root.geometry("210x150")
        self.root.resizable(False, False)
        
        # Timer settings (in seconds)
        self.work_duration = 25 * 60
        self.short_break = 5 * 60
        self.long_break = 15 * 60
        
        # State variables
        self.time_left = self.work_duration
        self.is_running = False
        self.is_work_session = True
        self.pomodoro_count = 0
        self.timer_id = None
        self.is_blinking = False
        self.blink_state = False
        self.original_bg = None
        
        self.setup_ui()
        self.update_display()
        
        # Bind click event to stop blinking
        self.root.bind("<Button-1>", self.stop_blinking)
        
    def setup_ui(self):
        # Session type label (compact)
        self.session_label = tk.Label(
            self.root,
            text="Work",
            font=("Arial", 10, "bold"),
            fg="#d32f2f"
        )
        self.session_label.pack(pady=(8, 2))
        
        # Timer display
        self.timer_label = tk.Label(
            self.root,
            text="25:00",
            font=("Arial", 32, "bold"),
            fg="#000000"
        )
        self.timer_label.pack(pady=2)
        
        # Pomodoro count (compact)
        self.count_label = tk.Label(
            self.root,
            text="0/4",
            font=("Arial", 8),
            fg="#666666"
        )
        self.count_label.pack(pady=2)
        
        # Button frame (compact buttons)
        button_frame = tk.Frame(self.root)
        button_frame.pack(pady=5)
        
        # Start/Pause button
        self.start_button = tk.Button(
            button_frame,
            text="Start",
            command=self.toggle_timer,
            font=("Arial", 9),
            bg="#4caf50",
            fg="white",
            width=6,
            height=1,
            cursor="hand2"
        )
        self.start_button.grid(row=0, column=0, padx=2)
        
        # Reset button
        self.reset_button = tk.Button(
            button_frame,
            text="Reset",
            command=self.reset_timer,
            font=("Arial", 9),
            bg="#ff9800",
            fg="white",
            width=6,
            height=1,
            cursor="hand2"
        )
        self.reset_button.grid(row=0, column=1, padx=2)
        
        # Settings button
        self.settings_button = tk.Button(
            button_frame,
            text="⚙",
            command=self.open_settings,
            font=("Arial", 9),
            bg="#2196f3",
            fg="white",
            width=3,
            height=1,
            cursor="hand2"
        )
        self.settings_button.grid(row=0, column=2, padx=2)
        
    def toggle_timer(self):
        if self.is_running:
            self.pause_timer()
        else:
            self.start_timer()
            
    def start_timer(self):
        self.is_running = True
        self.start_button.config(text="Pause", bg="#f44336")
        self.countdown()
        
    def pause_timer(self):
        self.is_running = False
        self.start_button.config(text="Start", bg="#4caf50")
        if self.timer_id:
            self.root.after_cancel(self.timer_id)
            
    def reset_timer(self):
        self.is_running = False
        if self.timer_id:
            self.root.after_cancel(self.timer_id)
        
        self.is_work_session = True
        self.time_left = self.work_duration
        self.start_button.config(text="Start", bg="#4caf50")
        self.session_label.config(text="Work", fg="#d32f2f")
        self.update_display()
        
    def countdown(self):
        if self.is_running and self.time_left > 0:
            self.time_left -= 1
            self.update_display()
            self.timer_id = self.root.after(1000, self.countdown)
        elif self.time_left == 0:
            self.timer_finished()
            
    def timer_finished(self):
        self.is_running = False
        
        if self.is_work_session:
            self.pomodoro_count += 1
            
            # Determine break type
            if self.pomodoro_count % 4 == 0:
                self.time_left = self.long_break
                self.session_label.config(text="Long Break", fg="#7b1fa2")
            else:
                self.time_left = self.short_break
                self.session_label.config(text="Break", fg="#388e3c")
            
            self.is_work_session = False
        else:
            # Switch back to work session
            self.time_left = self.work_duration
            self.session_label.config(text="Work", fg="#d32f2f")
            self.is_work_session = True
        
        self.start_button.config(text="Start", bg="#4caf50")
        self.update_display()
        self.root.bell()
        
        # Start continuous blinking effect
        self.is_blinking = True
        self.original_bg = self.root.cget('bg')
        self.blink_window()
        
    def update_display(self):
        minutes = self.time_left // 60
        seconds = self.time_left % 60
        self.timer_label.config(text=f"{minutes:02d}:{seconds:02d}")
        
        # Update count label
        self.count_label.config(text=f"{self.pomodoro_count % 4}/4")
    
    def blink_window(self):
        """Blink the window background with a catchy color continuously"""
        if self.is_blinking:
            if self.blink_state:
                # Set to bright attention-grabbing color
                self.root.config(bg="#FF6B35")  # Bright orange
            else:
                # Return to original color
                self.root.config(bg=self.original_bg)
            
            self.blink_state = not self.blink_state
            self.root.after(300, self.blink_window)  # Blink every 300ms
    
    def stop_blinking(self, event=None):
        """Stop the blinking effect when user clicks"""
        if self.is_blinking:
            self.is_blinking = False
            self.root.config(bg=self.original_bg)
        
    def open_settings(self):
        settings_window = tk.Toplevel(self.root)
        settings_window.title("Settings")
        settings_window.geometry("240x150")
        settings_window.resizable(False, False)
        settings_window.transient(self.root)
        settings_window.grab_set()
        
        # Work duration
        tk.Label(settings_window, text="Work Duration (minutes):", font=("Arial", 9)).grid(row=0, column=0, padx=10, pady=3, sticky="w")
        work_var = tk.StringVar(value=str(self.work_duration // 60))
        work_entry = tk.Entry(settings_window, textvariable=work_var, width=8, font=("Arial", 9))
        work_entry.grid(row=0, column=1, padx=10, pady=3)
        
        # Short break duration
        tk.Label(settings_window, text="Short Break (minutes):", font=("Arial", 9)).grid(row=1, column=0, padx=10, pady=3, sticky="w")
        short_var = tk.StringVar(value=str(self.short_break // 60))
        short_entry = tk.Entry(settings_window, textvariable=short_var, width=8, font=("Arial", 9))
        short_entry.grid(row=1, column=1, padx=10, pady=3)
        
        # Long break duration
        tk.Label(settings_window, text="Long Break (minutes):", font=("Arial", 9)).grid(row=2, column=0, padx=10, pady=3, sticky="w")
        long_var = tk.StringVar(value=str(self.long_break // 60))
        long_entry = tk.Entry(settings_window, textvariable=long_var, width=8, font=("Arial", 9))
        long_entry.grid(row=2, column=1, padx=10, pady=3)
        
        def save_settings():
            try:
                work_mins = int(work_var.get())
                short_mins = int(short_var.get())
                long_mins = int(long_var.get())
                
                if work_mins <= 0 or short_mins <= 0 or long_mins <= 0:
                    raise ValueError("Values must be positive")
                
                self.work_duration = work_mins * 60
                self.short_break = short_mins * 60
                self.long_break = long_mins * 60
                
                # Reset timer to apply new settings
                self.reset_timer()
                
                settings_window.destroy()
            except ValueError:
                error_label.config(text="Please enter valid positive numbers")
        
        # Error label
        error_label = tk.Label(settings_window, text="", font=("Arial", 8), fg="red")
        error_label.grid(row=3, column=0, columnspan=2, pady=5)
        
        # Button frame
        button_frame = tk.Frame(settings_window)
        button_frame.grid(row=4, column=0, columnspan=2, pady=1)
        
        save_button = tk.Button(
            button_frame,
            text="Save",
            command=save_settings,
            font=("Arial", 9),
            bg="#4caf50",
            fg="white",
            width=8,
            cursor="hand2"
        )
        save_button.pack(side="left", padx=5)
        
        cancel_button = tk.Button(
            button_frame,
            text="Cancel",
            command=settings_window.destroy,
            font=("Arial", 9),
            bg="#f44336",
            fg="white",
            width=8,
            cursor="hand2"
        )
        cancel_button.pack(side="left", padx=5)
        
def main():
    root = tk.Tk()
    app = PomodoroTimer(root)
    root.mainloop()

if __name__ == "__main__":
    main()
