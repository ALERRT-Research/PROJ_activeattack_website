# 2026-11-09: Remembrance scroll video rebuilt

Peter: same structure as before (short front matter for context, then the names scrolling), sharper look. Previews
of the title card, a mid-scroll frame and the closing card approved before the full encode.

## Graphics (`code/plots_victims.R`, rewritten)

- 1920 x 1080, 30 fps, 6 min 39 s, 11.9 MB; the old file was 800 x 600 at 25 fps, 5 min, Arial on black, with
  colour as the only marker for officers and minors.
- Site look: the dark page (#141a21), Public Sans, ink/muted text. Title card: eyebrow, "Remembrance", the two counts
  (1,434 names of 1,477 people killed, 2000 to 2025), the honour sentence from the web page, a legend for the two
  tags. Then one block per year (year, "n people", rule, names in three columns in attack-date order, first-name
  order as on the web page) with "Officer" / "Under 18" pills after the name. Closing card: 1,477, the correction
  request, the URL. Hold 7 s at each end, 92 px/s scroll, 2.5 s fade.
- Method: every block is drawn with grid on a ragg device (res 72, so 1 pt = 1 px; grid has no "px" unit, use
  "bigpts") and stacked with magick into one tall image (36,530 px). ffmpeg through `av` loops that still and crops
  a 1080-px window that slides down it: `loop=...,crop=1920:1080:0:'clip((n-hold)*px,0,max)',setpts=N/(30*TB),fade=...`.
  No frame files; the encode takes about six minutes. **`setpts` is required**: without it every looped frame carries
  the same timestamp and av writes a "1000 fps, 12 s" file (and `av_video_images()` segfaults on it).
- `AA_PREVIEW=1 Rscript plots_victims.R` writes `output/preview/scroll_{title,mid,end}.png`; the title still is the
  web player's poster. Names without a recorded name (13) are not listed; the title card gives both counts.
- gganimate is no longer used here (it rendered ~7,700 frames through ggplot).

## Website

- `2_victims.qmd`: "Memorial video" section with a `<video controls preload="none">` player (poster = title card)
  and a plain download link styled as the site button (`main a.aa-dl` in `aa-theme.css`). The downloadthis button
  had embedded the whole MP4 as base64 in the page; a 12 MB video would have made the page unusable.
- `0_set_up.R` `update_aa_victim_scroll()` also copies the poster. Changelog entry on Home.
