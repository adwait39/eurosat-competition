# ASEN 6337 — EuroSAT land cover competition

Everything you need to enter the group project competition. Start here.

---

## 1. Get the data

The data files are too large for this repository, so they are attached to the
**[Releases](https://github.com/adwait39/eurosat-competition/releases)** page instead. Download from there.

| File | Size | Take this if |
|---|---|---|
| `train.npz` | 1.3 GB | you work in **Python** |
| `test.npz` | 591 MB | you work in **Python** |
| `train.mat` | 1.2 GB | you work in **MATLAB** |
| `test.mat` | 508 MB | you work in **MATLAB** |

Take one pair, not both. The `.npz` and `.mat` files hold identical data; MATLAB
cannot read `.npz`, which is the only reason both exist.

<details>
<summary>Checksums, if your download looks damaged</summary>

```
train.npz  e2763932671541e4dd2e12f1df9cc867e5d521d10795bd7b21197dd14859a2f6
test.npz   91b08d87e8b1a984571c4d571aa3637164fad6974a506ec09c493d1bb2681216
train.mat  081ee9496c001cb35d6cbd405c1803b50295ec2546be473d7f0e000915149b1e
test.mat   1ac4b55664049504522633e7376c4e5864561e23adab09e0e7b6b3a5eef281cb
```

Check one with `certutil -hashfile train.npz SHA256` on Windows, or
`shasum -a 256 train.npz` on macOS and Linux.
</details>

---

## 2. What is in it

27,000 satellite patches from Sentinel-2, covering 34 European countries. Each
patch is 64 by 64 pixels, and every pixel carries **13 numbers** rather than the
usual three, because the satellite measures far more than visible light.

```
train.npz    X  (18900, 64, 64, 13)  uint16     the patches
             y  (18900,)             int64      label index, 0 to 9
             classes (10,)           str        the class names

test.npz     X  (8100, 64, 64, 13)   uint16     the patches
             id (8100,)              int64      the id to put in your answer file
```

Ten classes: AnnualCrop, Forest, HerbaceousVegetation, Highway, Industrial,
Pasture, PermanentCrop, Residential, River, SeaLake.

The 18,900 training patches come with labels. The 8,100 test patches do not.
Working out those 8,100 labels is the competition.

---

## 3. Look at it before you model it

The data arrives as numbers, not as pictures. **[VIEWING_THE_DATA.md](VIEWING_THE_DATA.md)**
shows you how to turn it back into something you can see, in Python and in
MATLAB, and explains the one mistake that catches almost everybody.

```bash
python view_patches.py                 # one example of each class
python view_patches.py --false-colour  # infrared, vegetation turns red
python view_patches.py --index 17      # one patch, all 13 bands
```

---

## 4. Run the baseline

```bash
python baseline.py
```

Per-band averages and variability, 26 numbers per patch, into a random forest.
No neural network and no use of the spatial arrangement at all. It takes about a
minute on a laptop and writes a valid `submission.csv`.

This is the score you are trying to beat, and it is deliberately beatable.

---

## 5. Hand in your answers

One file. Two columns. 8,101 lines: a heading, then one line per test patch.

```
id,label
359356,AnnualCrop
752130,Forest
206827,SeaLake
```

Copy `sample_submission.csv`, which already has all 8,100 ids in it, leave the
`id` column alone, and overwrite the `label` column with your own answers.
**[MAKING_YOUR_SUBMISSION.md](MAKING_YOUR_SUBMISSION.md)** shows the code for
this in Python and MATLAB.

Before you upload, check the file:

```bash
python check_submission.py my_submission.csv     # or check_submission('...') in MATLAB
```

It tells you whether the file will be accepted, and what to fix if not. It takes
a second and it saves you a wasted round.

**Upload it to the Canvas assignment for that round.** One upload per team.
Upload as often as you like before the deadline; the most recent one is the one
scored. Nothing else is handed in during the competition: no code, no images.

Spell the class names exactly as they appear above. A file with a missing row, a
repeated row, or a misspelled class is rejected and you are told which row is at
fault.

---

## 6. How the leaderboard works

**The competition carries no marks.** It is here to give you a target, something
to argue about, and a reason to look hard at your own results. Your report and
your oral presentation are what count. A team with a simple model and a careful
report finishes well above a team with a complicated model and a thin one.

### How a team is judged

Only on the predictions file. I never run your code, and nothing about your
method enters the comparison. Whether you used clustering, a support vector
machine or a neural network, what reaches me is the same two columns, and the
same script scores every team against the same answer key.

The measure is **macro-F1**. For each of the ten classes I work out an F1 score,
which is high only when you find most of that class and do not wrongly label
other things as it. Then I average the ten, weighting each class equally.

That last part matters. Accuracy lets a model hide a failure: handle nine
classes well, never predict Pasture at all, and accuracy barely notices because
Pasture is a small part of the set. Macro-F1 makes you pay a full tenth of your
score for it.

### How teams are ranked

| | |
|---|---|
| Ranked by | macro-F1, highest first |
| Also shown | overall accuracy, which does not affect position |
| Ties broken by | accuracy, then by whoever submitted earlier |
| Which file counts | your most recent upload in that round |
| Invalid files | do not rank; I tell you which row is at fault so you can fix it |

### The two halves, and why

The 8,100 test patches are split in half at random. You cannot tell which patch
is in which half.

- The leaderboard during the competition is scored on one half.
- The final ranking, after the close, is scored on the other half.

This is not about catching anyone out. It is so that the final ranking means
something. If you tune your model by watching the leaderboard rather than by
using your own validation set, your final score drops when the other half is
revealed, and the size of that gap tells you exactly how much you were fitting
the leaderboard instead of the problem. That is worth knowing, and it is a good
thing to write about in your report.

### How this stays fair across different methods

- The same training data, test data, answer key, scoring script and deadlines
  for every team.
- No pretrained weights and no outside data, so no team starts ahead.
- Nothing is ranked against a threshold or a quota. Two teams with the same
  score get the same position.
- Which half is which is hidden from everyone equally, and was fixed before the
  competition opened.

---

## 7. Dates

| Date | What happens |
|---|---|
| Mon 5 Oct | Data released |
| Mon 2 Nov | Round 1 predictions due on Canvas |
| Wed 4 Nov | Round 1 scores and leaderboard posted on Canvas |
| Mon 9 Nov | Round 2 predictions due on Canvas |
| Wed 11 Nov | Round 2 scores and leaderboard posted on Canvas |
| Fri 13 Nov, 5 pm | Canvas closes, your last upload is your final entry |
| Sun 15 Nov | Final scores posted on Canvas |
| Mon 16 and Wed 18 Nov | Oral presentations |
| Fri 20 Nov | Written report and code due |

---

The full competition guide is on Canvas, along with the submission guidelines
for the report and the oral presentation, which are where your marks actually
come from. The rules for the competition are in that guide.

---

## 8. Questions

Email me at **adde8370@colorado.edu** with `ASEN 6337` in the subject line. If a
question turns out to matter for everybody, I will answer it to the whole class
so that no team gets an advantage from having asked.

---

## Data source and licence

EuroSAT, by Patrick Helber, Benjamin Bischke, Andreas Dengel and Damian Borth.

> Helber, P., Bischke, B., Dengel, A. and Borth, D. (2019). *EuroSAT: A Novel
> Dataset and Deep Learning Benchmark for Land Use and Land Cover
> Classification.* IEEE Journal of Selected Topics in Applied Earth Observations
> and Remote Sensing.

Original data: [github.com/phelber/EuroSAT](https://github.com/phelber/EuroSAT),
Zenodo DOI 10.5281/zenodo.7711810, MIT licence. The patches here are the original
data, repackaged as arrays and split into a training and a test set. The band
order has been corrected to canonical Sentinel-2 order, so B8A is the ninth band
rather than the last. Nothing else was altered.

Code in this repository is MIT licensed. See [LICENSE](LICENSE).
