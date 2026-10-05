# Turning the numbers back into pictures

The data arrives as arrays of numbers rather than as image files. This page shows you
how to look at it. None of this is needed to compete, but looking at your data before
you model it is usually time well spent, and the report asks you to discuss what the
classes actually look like.

Run `python view_patches.py` in the folder with `train.npz` and it writes a picture of
one example from each of the ten classes. The rest of this page explains what that
script is doing, so you can do it yourself.

---

## 1. What is actually in the file

```
train.npz    X  (18900, 64, 64, 13)  uint16
test.npz     X  (8100,  64, 64, 13)  uint16
```

Read that shape as: *this many patches, 64 pixels down, 64 pixels across, 13 numbers
per pixel.* One patch is one picture. Ordinary photographs have 3 numbers per pixel
(red, green, blue). These have 13.

Each number is a reflectance measurement multiplied by 10,000. Reflectance is the
fraction of sunlight that bounced back off the ground, so a value of 1200 means about
12 percent of the light came back. Dark things like water return very little, bright
things like concrete return a lot.

The 13 bands, in the order they are stored:

| Index (Python) | Band | Wavelength (nm) | What it sees |
|---|---|---|---|
| 0 | B01 | 443 | Aerosols, haze |
| 1 | B02 | 490 | **Blue** |
| 2 | B03 | 560 | **Green** |
| 3 | B04 | 665 | **Red** |
| 4 | B05 | 705 | Red edge |
| 5 | B06 | 740 | Red edge |
| 6 | B07 | 783 | Red edge |
| 7 | B08 | 842 | **Near infrared** |
| 8 | B8A | 865 | Narrow near infrared |
| 9 | B09 | 945 | Water vapour |
| 10 | B10 | 1375 | Cirrus cloud (nearly empty in this data) |
| 11 | B11 | 1610 | Shortwave infrared |
| 12 | B12 | 2190 | Shortwave infrared |

In MATLAB every index above is one higher, because MATLAB counts from 1. B04 is index
4 in MATLAB, index 3 in Python.

---

## 2. A true colour picture

A picture your eye understands uses three of the thirteen bands: B04 as red, B03 as
green, B02 as blue.

```python
import numpy as np
import matplotlib.pyplot as plt

d = np.load('train.npz')
X, y = d['X'], d['y']
classes = [str(c) for c in d['classes']]

patch = X[0]                               # (64, 64, 13)
rgb = patch[:, :, [3, 2, 1]]               # B04, B03, B02
rgb = np.clip(rgb.astype(np.float32) / 2500.0, 0, 1)

plt.imshow(rgb)
plt.title(classes[y[0]])
plt.axis('off')
plt.show()
```

### Why divide by 2500

If you hand the raw numbers straight to `imshow` you get a black square, because the
values run into the thousands while the drawing code expects 0 to 1. So you have to
rescale.

Over land, the visible bands in this dataset sit below about 2,500, so dividing by
2,500 and clipping puts most of the picture in range. Anything brighter than 25 percent
reflectance comes out white, which is about right for roofs and bare ground.

**Use the same divisor for all three bands.** It is tempting to stretch each band
separately to its own minimum and maximum, and most tutorials show you that. It goes
badly wrong here. A patch of forest or open water is almost uniform, so it has very
little variation to stretch, and stretching it anyway magnifies the sensor noise until
the patch looks like coloured confetti. It also breaks the colour relationships
between the bands, so grass stops looking green. Dividing all three by the same fixed
number keeps the colours honest.

---

## 3. A false colour picture

Swap the near infrared band in for red, and shift the others along: B08 as red, B04 as
green, B03 as blue.

```python
fc = patch[:, :, [7, 3, 2]]                # B08, B04, B03
fc = np.clip(fc.astype(np.float32) / 2500.0, 0, 1)
```

Healthy vegetation reflects a lot of near infrared, so it turns bright red. Water
absorbs it almost completely, so it turns black. Built-up areas stay grey and white.
This is a standard way of looking at satellite data and it separates some of the
classes far better than the true colour view does. Compare Forest and SeaLake in both
and you will see the point immediately.

---

## 4. Looking at one band at a time

```python
fig, axes = plt.subplots(2, 7, figsize=(16, 5))
for i, ax in enumerate(axes.ravel()[:13]):
    ax.imshow(np.clip(patch[:, :, i] / 2500.0, 0, 1), cmap='gray', vmin=0, vmax=1)
    ax.set_title(['B01','B02','B03','B04','B05','B06','B07',
                  'B08','B8A','B09','B10','B11','B12'][i])
    ax.axis('off')
```

Or use the script: `python view_patches.py --index 17`.

Worth noticing: B10 is almost empty. It is the cirrus cloud band, and these patches
were chosen to be cloud free, so it carries almost no information. Finding that out
for yourself, and saying so in your report, is exactly the kind of observation the
marking rewards.

---

## 5. The same thing in MATLAB

```matlab
load('train.mat');                  % X, y, classes, bands
classes = cellstr(classes);

patch = X(1,:,:,:);                 % 1 x 64 x 64 x 13
patch = squeeze(patch);             % 64 x 64 x 13

% MATLAB indices are one higher than Python: B04 is 4, B03 is 3, B02 is 2
rgb = double(patch(:,:,[4 3 2])) / 2500;
rgb = min(max(rgb, 0), 1);

imshow(rgb);
title(classes{y(1)});

% false colour: B08, B04, B03
fc = min(max(double(patch(:,:,[8 4 3])) / 2500, 0), 1);
figure; imshow(fc); title('false colour');
```

`squeeze` is doing the work in the first few lines. `X(1,:,:,:)` keeps the leading
dimension of size 1, and `imshow` will not accept that, so `squeeze` removes it.

---

## 6. Saving a patch as an ordinary image file

If you want a PNG to put in your report:

```python
from PIL import Image
rgb8 = (np.clip(patch[:, :, [3, 2, 1]] / 2500.0, 0, 1) * 255).astype(np.uint8)
Image.fromarray(rgb8).resize((256, 256), Image.NEAREST).save('patch.png')
```

Use `NEAREST` when you enlarge. The patches are only 64 by 64, and smooth
interpolation invents detail that is not in the data, which is a bad habit in an
analysis of a satellite image.

---

## 7. A warning about the test set

`test.npz` has no `y`. That is deliberate. You can render test patches and look at them
exactly as above, and you are welcome to, but nothing in the file tells you the answer
and no amount of rendering will reveal it.
