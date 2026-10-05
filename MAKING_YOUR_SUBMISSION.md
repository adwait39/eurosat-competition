# Making your submission file

Your model produces predictions. This page turns those predictions into the file
you upload. It takes about four lines of code, and there is a checker in this
repository that tells you whether your file will be accepted before you upload
it.

---

## 1. Where the ids come from

You do not invent them. Every test patch has an id that I assigned when I built
the package, and you get them in two places:

- inside `test.npz` as the array `id`, in the same order as the images
- in `sample_submission.csv` in this repository, already written out in full

Either is fine. They are the same 8,100 ids.

**Row order does not matter.** I match your rows to mine by id, not by position.
What does matter is that every one of the 8,100 ids appears exactly once.

---

## 2. Python

Your model gives you one prediction per test patch, in the same order as
`test['X']`. The usual trap is that it gives you numbers, 0 to 9, when the file
needs class names.

```python
import numpy as np
import pandas as pd

test = np.load('test.npz')
classes = [str(c) for c in test['classes']]       # ['AnnualCrop', 'Forest', ...]

pred = my_model.predict(features)                 # array of 8100 numbers, 0 to 9
labels = [classes[i] for i in pred]               # turn them into names

out = pd.DataFrame({'id': test['id'], 'label': labels})
out.to_csv('my_submission.csv', index=False)
```

**`index=False` is not optional.** Without it pandas writes its own row number
as an extra first column and the file is rejected. This is the single most
common mistake.

If your model already returns names rather than numbers, skip the `classes`
lookup and pass the names straight in.

### Without pandas

```python
import csv, numpy as np

test = np.load('test.npz')
classes = [str(c) for c in test['classes']]
labels = [classes[i] for i in pred]

with open('my_submission.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['id', 'label'])
    w.writerows(zip(test['id'], labels))
```

---

## 3. MATLAB

```matlab
test = load('test.mat');
ids  = test.id;                      % 8100 x 1
load('train.mat', 'classes');
classes = cellstr(classes);

% pred is 8100 x 1 with values 1..10 (MATLAB counts from 1)
labels = classes(pred);

T = table(ids(:), string(labels(:)), 'VariableNames', {'id','label'});
writetable(T, 'my_submission.csv');
```

Watch the indexing. In MATLAB your class indices run 1 to 10, not 0 to 9. If you
trained on `y` from `train.mat`, that is already 1-based and matches `classes`
directly.

---

## 4. Check it before you upload

```bash
python check_submission.py my_submission.csv
```

or in MATLAB, from the folder holding `sample_submission.csv`:

```matlab
check_submission('my_submission.csv')
```

Both compare your file against `sample_submission.csv` and either accepts it or
tells you exactly what is wrong. Neither needs the test images, and neither can
tell you your score, because they have no labels. They answer one question:
will this be accepted?

A good run looks like this:

```
ACCEPTED
  8100 rows, all 8100 test ids present exactly once.
  Row order does not matter; ids are matched, not positions.

  how many of each class you predicted:
    AnnualCrop               812
    Forest                   903
    ...
```

A bad one tells you the fix:

```
REJECTED
  the label column holds numbers, not class names. Found '4'.
  Your model predicts an index 0 to 9. Convert it with the classes array:
      labels = [classes[i] for i in pred]
```

The checker also prints how many of each class you predicted. If a class comes
out at zero, that is worth investigating before you upload: the score averages
all ten classes equally, so a class you never predict scores zero and drags the
average down regardless of how well you do elsewhere.

---

## 5. Updating your submission

Upload to the Canvas assignment for that round. You may upload as many times as
you like before the deadline, and **the most recent upload is the one scored**,
so a new upload replaces the previous one rather than adding to it.

There is no way to withdraw an upload and go back to an earlier one, so if you
are unsure, check the file before uploading rather than after.

---

## 6. Mistakes that get files rejected

| What happened | What you see | Fix |
|---|---|---|
| Pandas wrote its row index | extra column before `id` | `to_csv(..., index=False)` |
| Labels are numbers | `label column holds numbers` | map through `classes` |
| Class name spelled loosely | `'Sea Lake' should be 'SeaLake'` | copy the names exactly |
| Some rows dropped | `n test ids have no prediction` | predict for all 8,100 |
| File opened and saved in Excel | ids altered, or rows reformatted | keep it in code, do not round-trip through Excel |
| Header renamed | `first line must be exactly: id,label` | restore the header |

The exact class names, which are case sensitive and have no spaces:

```
AnnualCrop  Forest  HerbaceousVegetation  Highway  Industrial
Pasture  PermanentCrop  Residential  River  SeaLake
```
