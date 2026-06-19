#!/usr/bin/env bash
# IRTH — Phase 04 media compression
# Run from the project root:  bash compress-media.sh
# Requires ffmpeg on PATH. Produces dual-source (H.264 mp4 + VP9 webm) + poster frames.
#
# NOTE: plan used libx265 (HEVC). Chrome/Firefox can't decode HEVC in <video>,
# so we use libx264 (universal) for mp4 and libvpx-vp9 for webm.
set -euo pipefail
cd "$(dirname "$0")/assets"

echo "== HERO (muted -> strip audio) =="
# Desktop H.264
ffmpeg -y -i hero.mp4 -c:v libx264 -crf 23 -preset slow -vf "scale=1920:-2" -r 24 -an -movflags +faststart hero-desktop.mp4
# Desktop VP9 (smaller on Chrome/FF)
ffmpeg -y -i hero.mp4 -c:v libvpx-vp9 -crf 33 -b:v 0 -vf "scale=1920:-2" -r 24 -an hero-desktop.webm
# Mobile H.264
ffmpeg -y -i hero.mp4 -c:v libx264 -crf 28 -preset slow -vf "scale=854:-2" -r 20 -an -movflags +faststart hero-mobile.mp4
# Mobile VP9
ffmpeg -y -i hero.mp4 -c:v libvpx-vp9 -crf 36 -b:v 0 -vf "scale=854:-2" -r 20 -an hero-mobile.webm
# Poster frame (1s in to avoid black first frame)
ffmpeg -y -ss 1 -i hero.mp4 -vframes 1 -q:v 2 hero-poster.jpg

echo "== TRANSITION (keep audio) =="
ffmpeg -y -i transition.mp4 -c:v libx264 -crf 23 -preset slow -vf "scale=1920:-2" -r 24 -c:a aac -b:a 128k -movflags +faststart transition-desktop.mp4
ffmpeg -y -i transition.mp4 -c:v libvpx-vp9 -crf 33 -b:v 0 -vf "scale=1920:-2" -r 24 -c:a libopus -b:a 128k transition-desktop.webm
ffmpeg -y -i transition.mp4 -c:v libx264 -crf 28 -preset slow -vf "scale=854:-2"  -r 20 -c:a aac -b:a 96k  -movflags +faststart transition-mobile.mp4
ffmpeg -y -i transition.mp4 -c:v libvpx-vp9 -crf 36 -b:v 0 -vf "scale=854:-2"  -r 20 -c:a libopus -b:a 96k transition-mobile.webm
ffmpeg -y -ss 1 -i transition.mp4 -vframes 1 -q:v 2 transition-poster.jpg

echo "== INTRO VIDEO (architecture cinematic, muted, no audio) =="
# Desktop H.264  — target ~400KB for 10s 720p
ffmpeg -y -i intro.mp4 -c:v libx264 -crf 26 -preset slow -vf "scale=1280:-2" -r 24 -an -movflags +faststart intro-desktop.mp4
# Desktop VP9 — even smaller on Chrome/FF (~250KB)
ffmpeg -y -i intro.mp4 -c:v libvpx-vp9 -crf 32 -b:v 0 -vf "scale=1280:-2" -r 24 -an intro-desktop.webm
# Mobile H.264 — 640x360, aggressive compress
ffmpeg -y -i intro.mp4 -c:v libx264 -crf 30 -preset slow -vf "scale=640:-2" -r 24 -an -movflags +faststart intro-mobile.mp4
# Mobile VP9
ffmpeg -y -i intro.mp4 -c:v libvpx-vp9 -crf 36 -b:v 0 -vf "scale=640:-2" -r 24 -an intro-mobile.webm
# Poster at 2s (past any black opener)
ffmpeg -y -ss 2 -i intro.mp4 -vframes 1 -q:v 2 intro-poster.jpg

echo "Done. Compare sizes:"
ls -lh hero*.mp4 hero*.webm hero-poster.jpg transition*.mp4 transition*.webm transition-poster.jpg intro*.mp4 intro*.webm intro-poster.jpg
