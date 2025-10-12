#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk

class PomodoroTimer:
    def __init__(self, root):
        self.root = root
        self.root.title("Pomodoro")
        self.root.geometry("200x120")
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
        
        self.setup_ui()
        self.update_display()
        
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
            text="strt",
            command=self.toggle_timer,
            font=("Arial", 10, "bold"),
            bg="#4caf50",
            fg="white",
            width=4,
            height=1,
            cursor="hand2"
        )
        self.start_button.grid(row=0, column=0, padx=2)
        
        # Reset button
        self.reset_button = tk.Button(
            button_frame,
            text="rst",
            command=self.reset_timer,
            font=("Arial", 10, "bold"),
            bg="#ff9800",
            fg="white",
            width=4,
            height=1,
            cursor="hand2"
        )
        self.reset_button.grid(row=0, column=1, padx=2)
        
    def toggle_timer(self):
        if self.is_running:
            self.pause_timer()
        else:
            self.start_timer()
            
    def start_timer(self):
        self.is_running = True
        self.start_button.config(text="⏸", bg="#f44336")
        self.countdown()
        
    def pause_timer(self):
        self.is_running = False
        self.start_button.config(text="▶", bg="#4caf50")
        if self.timer_id:
            self.root.after_cancel(self.timer_id)
            
    def reset_timer(self):
        self.is_running = False
        if self.timer_id:
            self.root.after_cancel(self.timer_id)
        
        self.is_work_session = True
        self.time_left = self.work_duration
        self.start_button.config(text="▶", bg="#4caf50")
        self.session_label.config(text="🍅 Work", fg="#d32f2f")
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
        
        self.start_button.config(text="strt", bg="#4caf50")
        self.update_display()
        self.root.bell()
        
    def update_display(self):
        minutes = self.time_left // 60
        seconds = self.time_left % 60
        self.timer_label.config(text=f"{minutes:02d}:{seconds:02d}")
        
        # Update count label
        current = self.pomodoro_count % 4 if self.pomodoro_count % 4 != 0 else 4
        if not self.is_work_session and self.pomodoro_count % 4 == 0:
            current = 4
        elif not self.is_work_session:
            current = self.pomodoro_count % 4
        else:
            current = (self.pomodoro_count % 4)
        
        self.count_label.config(text=f"{self.pomodoro_count % 4}/4")
        
def main():
    root = tk.Tk()
    app = PomodoroTimer(root)
    root.mainloop()

if __name__ == "__main__":
    main()
