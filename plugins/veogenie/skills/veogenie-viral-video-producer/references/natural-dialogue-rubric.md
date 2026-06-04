# Natural Dialogue Rubric

Use this before writing spoken lines for `videoGenerate` prompts.

## Human Dialogue Rules

- Write for speaking, not reading.
- Keep one spoken line per short scene unless the duration is `8-10s`.
- For `4-6s`, use one sentence or two very short sentences.
- For `8-10s`, use up to two sentences.
- Prefer concrete words, small imperfections, and a clear point of view.
- Let the visual carry some information; do not explain everything in the voice.
- Use the requested language. If the user asks Vietnamese, write natural Vietnamese without formal corporate phrasing.

## Avoid AI-Sounding Lines

Avoid lines like:

- "Xin chao cac ban, hom nay chung ta se cung nhau kham pha..."
- "Day la mot giai phap tuyet voi giup nang cao trai nghiem cua ban."
- "Hay cung toi tim hieu ve san pham doc dao nay."
- "Voi cong nghe hien dai, chung toi mang den..."
- Long balanced sentences with too many adjectives.

Better:

- "Khoan, canh nay bi gia o dung mot cho."
- "Nghe cau nay ne, no moi giong nguoi noi that."
- "Toi doi moi mot chi tiet, va video khac han."
- "Neu ban muon giong noi tu nhien, dung viet cau dai nhu quang cao."

## Voice Direction Pattern

Put the exact spoken line and tone in the video prompt:

```text
Vietnamese spoken line, natural casual tone, slight smile, not announcer-like: "Khoan, canh nay bi gia o dung mot cho."
```

For character dialogue:

```text
The character speaks Vietnamese softly, like talking to a friend, with a tiny pause after the first phrase: "Dung cuoi voi. Cai nay that su da cuu toi sang nay."
```

## Dialogue QA

Before using a line:

- It can be spoken in one breath.
- It has a clear emotion: surprise, doubt, relief, urgency, pride, or humor.
- It does not sound like a narrator reading a marketing paragraph.
- It does not duplicate what the viewer can already see.
- It fits the selected voice reference and the character's age/persona.
- It does not ask for subtitles or visible text unless the user explicitly requested text overlays.
