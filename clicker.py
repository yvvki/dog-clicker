#!/usr/bin/env python3
import pygame 
import os
import sys

# --- Configuration ---
TARGET_KEY = pygame.K_a
BG_COLOR = (30, 30, 30)
RED_NORMAL = (220, 60, 60)
RED_DARK = (130, 30, 30)

# Paths
script_dir = os.path.dirname(os.path.realpath(__file__))
ON_SOUND_FILE = os.path.join(script_dir, "CLICKER-ON.wav")
OFF_SOUND_FILE = os.path.join(script_dir, "CLICKER-OFF.wav")

def main():
    pygame.init()
    
    # Audio Setup
    try:
        pygame.mixer.pre_init(44100, -16, 2, 512)
        pygame.mixer.init()
        sound_on = pygame.mixer.Sound(ON_SOUND_FILE)
        sound_off = pygame.mixer.Sound(OFF_SOUND_FILE)
    except Exception:
        sound_on = None
        sound_off = None

    # pygame-ce: Automatic resizing surface
    screen = pygame.display.set_mode((400, 400), pygame.RESIZABLE)
    pygame.display.set_caption("Clicker")

    font = pygame.font.Font(None, 24)
    text_surf = font.render("Press 'A' or Left Click", True, (150, 150, 150))

    running = True
    
    # Input States
    key_held = False
    mouse_held = False
    
    # Logic State (prevents stuttering if you hold both)
    is_active = False

    pygame.key.set_repeat()

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                 running = False
            
            # --- KEYBOARD ---
            elif event.type == pygame.KEYDOWN:
                if event.key == TARGET_KEY:
                    key_held = True

            elif event.type == pygame.KEYUP:
                if event.key == TARGET_KEY:
                    key_held = False

            # --- MOUSE (Left Button Only) ---
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1: # 1=Left, 2=Middle, 3=Right
                    mouse_held = True
            
            elif event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    mouse_held = False

        # --- UNIFIED LOGIC ---
        # If EITHER is held, we are "active"
        should_be_active = key_held or mouse_held

        # 1. State changed from OFF to ON (Press)
        if should_be_active and not is_active:
            if sound_on: sound_on.play()
            is_active = True
        
        # 2. State changed from ON to OFF (Release)
        elif not should_be_active and is_active:
            if sound_off: sound_off.play()
            is_active = False

        # --- DRAWING ---
        w, h = screen.get_size()
        if w == 0 or h == 0: continue # Skip 1px glitches

        screen.fill(BG_COLOR)

        # Visuals follow the active state
        color = RED_DARK if is_active else RED_NORMAL

        center = (w // 2, h // 2)
        radius = min(w, h) * 0.25 

        pygame.draw.circle(screen, color, center, int(radius))
        
        text_rect = text_surf.get_rect(center=(w//2, h - 20))
        screen.blit(text_surf, text_rect)

        pygame.display.flip()
        pygame.time.Clock().tick(60)

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()
