"""
Audio generator for Little Learners app.
Generates all SFX and background music WAV files using numpy.
Run: python tools/generate_audio.py
"""

import numpy as np
import wave
import os

SAMPLE_RATE = 44100


# ── Helpers ───────────────────────────────────────────────────────────────────

NOTE_NAMES = {
    'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
    'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7,
    'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11,
}


def freq(note: str, octave: int = 4) -> float:
    semitones = NOTE_NAMES[note] + (octave - 4) * 12
    return 440.0 * (2.0 ** ((semitones - 9) / 12.0))


def tone(hz: float, duration: float, volume: float = 0.45,
         attack: float = 0.01, release: float = 0.06) -> np.ndarray:
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)

    # Sine + harmonics for warmth
    wave_data = (
        np.sin(2 * np.pi * hz * t)
        + 0.30 * np.sin(2 * np.pi * hz * 2 * t)
        + 0.12 * np.sin(2 * np.pi * hz * 3 * t)
        + 0.05 * np.sin(2 * np.pi * hz * 4 * t)
    )

    # ADSR-style envelope
    env = np.ones(n)
    atk = max(1, int(attack * SAMPLE_RATE))
    rel = max(1, int(release * SAMPLE_RATE))
    env[:atk] = np.linspace(0.0, 1.0, atk)
    if rel < n:
        env[-rel:] = np.linspace(1.0, 0.0, rel)

    return (wave_data * env * volume).astype(np.float32)


def rest(duration: float) -> np.ndarray:
    return np.zeros(int(SAMPLE_RATE * duration), dtype=np.float32)


def concat(*segments) -> np.ndarray:
    return np.concatenate(segments)


def save_wav(path: str, data: np.ndarray, volume: float = 0.88) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = np.clip(data * volume, -1.0, 1.0)
    pcm = (data * 32767).astype(np.int16)
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(pcm.tobytes())
    kb = os.path.getsize(path) // 1024
    print(f"  OK  {os.path.basename(path)}  ({kb} KB)")


def melody(notes: list, bpm: float = 120) -> np.ndarray:
    """
    notes: list of (note_name, octave, beats) or ('R', 0, beats) for rest.
    """
    beat = 60.0 / bpm
    segments = []
    for n, oct_, beats in notes:
        dur = beat * beats
        if n == 'R':
            segments.append(rest(dur))
        else:
            # tiny gap between notes for clarity
            note_dur = dur * 0.88
            gap_dur = dur * 0.12
            segments.append(tone(freq(n, oct_), note_dur))
            segments.append(rest(gap_dur))
    return concat(*segments)


def loop_to(data: np.ndarray, target_seconds: float) -> np.ndarray:
    target_samples = int(SAMPLE_RATE * target_seconds)
    if len(data) >= target_samples:
        return data[:target_samples]
    reps = (target_samples // len(data)) + 1
    return np.tile(data, reps)[:target_samples]


def fade_out(data: np.ndarray, seconds: float = 1.5) -> np.ndarray:
    n = int(SAMPLE_RATE * seconds)
    n = min(n, len(data))
    data = data.copy()
    data[-n:] *= np.linspace(1.0, 0.0, n)
    return data


# ── SFX ───────────────────────────────────────────────────────────────────────

def make_correct() -> np.ndarray:
    """Bright ascending 3-note chime."""
    return concat(
        tone(freq('E', 5), 0.12, volume=0.5),
        rest(0.03),
        tone(freq('G', 5), 0.12, volume=0.5),
        rest(0.03),
        tone(freq('C', 6), 0.28, volume=0.55, release=0.18),
    )


def make_wrong() -> np.ndarray:
    """Soft descending two-tone thud."""
    return concat(
        tone(freq('Bb', 3), 0.14, volume=0.4),
        rest(0.03),
        tone(freq('G', 3), 0.22, volume=0.35, release=0.15),
    )


def make_celebration() -> np.ndarray:
    """Happy ascending fanfare."""
    return concat(
        tone(freq('C', 5), 0.10, volume=0.45),
        rest(0.02),
        tone(freq('E', 5), 0.10, volume=0.45),
        rest(0.02),
        tone(freq('G', 5), 0.10, volume=0.45),
        rest(0.02),
        tone(freq('C', 6), 0.10, volume=0.50),
        rest(0.02),
        tone(freq('E', 6), 0.10, volume=0.50),
        rest(0.02),
        # Final chord
        (
            tone(freq('C', 5), 0.55, volume=0.20)
            + tone(freq('E', 5), 0.55, volume=0.20)
            + tone(freq('G', 5), 0.55, volume=0.20)
        ),
    )


def make_tap() -> np.ndarray:
    """Very short bright click."""
    return tone(freq('A', 5), 0.06, volume=0.38, attack=0.002, release=0.04)


# ── Background music ──────────────────────────────────────────────────────────

def make_jungle_theme() -> np.ndarray:
    """
    Jungle Jamboree — playful & bouncy, C major, 140 bpm.
    """
    bpm = 140
    phrase = melody([
        ('C', 5, 0.5), ('E', 5, 0.5), ('G', 5, 0.5), ('E', 5, 0.5),
        ('C', 5, 0.5), ('G', 4, 0.5), ('A', 4, 0.5), ('G', 4, 0.5),
        ('F', 4, 0.5), ('A', 4, 0.5), ('C', 5, 0.5), ('A', 4, 0.5),
        ('G', 4, 0.5), ('E', 4, 0.5), ('C', 4, 0.5), ('R', 0, 0.5),
    ], bpm=bpm)
    phrase2 = melody([
        ('E', 5, 0.5), ('D', 5, 0.5), ('C', 5, 0.5), ('B', 4, 0.5),
        ('A', 4, 0.5), ('G', 4, 0.5), ('A', 4, 1.0),
        ('C', 5, 0.5), ('B', 4, 0.5), ('A', 4, 0.5), ('G', 4, 0.5),
        ('F', 4, 0.5), ('E', 4, 0.5), ('C', 4, 1.0),
    ], bpm=bpm)
    loop_data = concat(phrase, phrase2)
    return fade_out(loop_to(loop_data, 12.0), seconds=1.5)


def make_ocean_theme() -> np.ndarray:
    """
    Ocean Cove — smooth & flowing, D major, 90 bpm.
    """
    bpm = 90
    phrase = melody([
        ('D', 4, 1.0), ('F#', 4, 1.0), ('A', 4, 1.0), ('F#', 4, 1.0),
        ('D', 4, 1.0), ('A', 4, 0.5), ('B', 4, 0.5), ('A', 4, 1.0),
        ('G', 4, 1.0), ('F#', 4, 1.0), ('E', 4, 1.0), ('D', 4, 1.0),
    ], bpm=bpm)
    phrase2 = melody([
        ('F#', 4, 1.0), ('G', 4, 1.0), ('A', 4, 1.0), ('B', 4, 1.0),
        ('A', 4, 0.5), ('F#', 4, 0.5), ('D', 4, 1.0), ('R', 0, 1.0),
        ('E', 4, 1.0), ('F#', 4, 1.0), ('G', 4, 1.0), ('A', 4, 2.0),
    ], bpm=bpm)
    loop_data = concat(phrase, phrase2)
    return fade_out(loop_to(loop_data, 16.0), seconds=2.0)


def make_space_theme() -> np.ndarray:
    """
    Starship ABC — mysterious & dreamy, A minor, 80 bpm.
    """
    bpm = 80
    phrase = melody([
        ('A', 3, 1.0), ('C', 4, 1.0), ('E', 4, 1.0), ('G', 4, 1.0),
        ('A', 4, 2.0), ('G', 4, 1.0), ('E', 4, 1.0),
        ('F', 4, 1.0), ('E', 4, 1.0), ('D', 4, 1.0), ('C', 4, 2.0),
    ], bpm=bpm)
    phrase2 = melody([
        ('E', 4, 1.0), ('G', 4, 1.0), ('A', 4, 1.0), ('B', 4, 1.0),
        ('C', 5, 2.0), ('B', 4, 1.0), ('A', 4, 1.0),
        ('G', 4, 1.0), ('E', 4, 1.0), ('A', 3, 3.0),
    ], bpm=bpm)
    loop_data = concat(phrase, phrase2)
    return fade_out(loop_to(loop_data, 18.0), seconds=2.0)


def make_candy_theme() -> np.ndarray:
    """
    Candy Kingdom — bright & sweet, G major, 160 bpm.
    """
    bpm = 160
    phrase = melody([
        ('G', 4, 0.5), ('B', 4, 0.5), ('D', 5, 0.5), ('B', 4, 0.5),
        ('G', 4, 0.5), ('D', 5, 0.5), ('E', 5, 0.5), ('D', 5, 0.5),
        ('C', 5, 0.5), ('B', 4, 0.5), ('A', 4, 0.5), ('G', 4, 0.5),
        ('A', 4, 0.5), ('B', 4, 0.5), ('C', 5, 1.0),
    ], bpm=bpm)
    phrase2 = melody([
        ('D', 5, 0.5), ('E', 5, 0.5), ('F#', 5, 0.5), ('E', 5, 0.5),
        ('D', 5, 0.5), ('B', 4, 0.5), ('G', 4, 1.0),
        ('C', 5, 0.5), ('B', 4, 0.5), ('A', 4, 0.5), ('G', 4, 0.5),
        ('F#', 4, 0.5), ('D', 4, 0.5), ('G', 4, 1.0),
    ], bpm=bpm)
    loop_data = concat(phrase, phrase2)
    return fade_out(loop_to(loop_data, 10.0), seconds=1.5)


def make_garden_theme() -> np.ndarray:
    """
    Enchanted Garden — peaceful & magical, F major, 100 bpm.
    """
    bpm = 100
    phrase = melody([
        ('F', 4, 1.0), ('A', 4, 1.0), ('C', 5, 1.0), ('A', 4, 1.0),
        ('F', 4, 1.0), ('C', 5, 0.5), ('D', 5, 0.5), ('C', 5, 1.0),
        ('Bb', 4, 1.0), ('A', 4, 1.0), ('G', 4, 1.0), ('F', 4, 1.0),
    ], bpm=bpm)
    phrase2 = melody([
        ('A', 4, 1.0), ('Bb', 4, 1.0), ('C', 5, 1.0), ('D', 5, 1.0),
        ('C', 5, 0.5), ('A', 4, 0.5), ('F', 4, 2.0),
        ('G', 4, 1.0), ('A', 4, 1.0), ('Bb', 4, 1.0), ('C', 5, 2.0),
    ], bpm=bpm)
    loop_data = concat(phrase, phrase2)
    return fade_out(loop_to(loop_data, 14.0), seconds=2.0)


# ── Main ──────────────────────────────────────────────────────────────────────

BASE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'assets', 'audio')


def main():
    print("\n== Generating SFX ==")
    sfx = os.path.join(BASE, 'sfx')
    save_wav(os.path.join(sfx, 'correct.wav'),     make_correct())
    save_wav(os.path.join(sfx, 'wrong.wav'),        make_wrong())
    save_wav(os.path.join(sfx, 'celebration.wav'),  make_celebration())
    save_wav(os.path.join(sfx, 'tap.wav'),          make_tap())

    print("\n== Generating Background Music ==")
    music = os.path.join(BASE, 'music')
    save_wav(os.path.join(music, 'jungle_theme.wav'),  make_jungle_theme())
    save_wav(os.path.join(music, 'ocean_theme.wav'),   make_ocean_theme())
    save_wav(os.path.join(music, 'space_theme.wav'),   make_space_theme())
    save_wav(os.path.join(music, 'candy_theme.wav'),   make_candy_theme())
    save_wav(os.path.join(music, 'garden_theme.wav'),  make_garden_theme())
    save_wav(os.path.join(music, 'home_theme.wav'),    make_garden_theme())  # reuse for home

    print("\nAll audio files generated successfully!\n")


if __name__ == '__main__':
    main()
