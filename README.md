# AVsitter support for extra animations

By Typhaine Artez. **Version 1.0** *- March 2021*

Provided under Creative Commons [Attribution-Non-Commercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Please be sure you read and adhere to the terms of this license.


This script is a plugin for AVsitter 2, adding support to play extra animations on configured poses. It is useful to play bento hands and face animations. It can be used to replace the system face expressions for bento heads, provided you get animations similar to the system expressions.

## Features

* Relies on the `AVpos` menu configuration (sitters and poses)
* Play one or several extra animations on each pose (combine bento hands and face for example)
* Made for, but not limited to bento specific animations (you can use the plugin to play any extra animation on each pose)
* Configure default animations to be always played for unconfigured poses

## USAGE

1) Drop the `[AV]anim` script in your object containing an existing setup of AVsitter.
2) Create a notecard `AVanim` and drop it in your object.
3) Edit the `AVanim` notecard to configure poses (each time the `AVanim` notecard is modified, the script read it again).

## AVanim notecard format

Blank lines and lines starting with a `#` are ignored (thus `#` denotes the beginning of a comment line).

### DEFAULT

```
DEFAULT {seat#}|{animations-list}
```

Defines animations to be played when a pose is played and has not been configured to play specific extra animations.
* `{seat#}` is the *SITTER* number this line refers to (so it is possible to have different default animations for each seat)
* `{animations-list}` is a list of animations to play, separated by a semi-colon character (`;`)

Example:
```
DEFAULT 0|RestBentoHead
DEFAULT 1|CloseEyes;OpenHandRight;OpenHandLeft
```

### SITTER

```
SITTER {seat#}
```

Starts the section for a seat. All following lines will be applied to this seat until another `SITTER` command is found.

### Poses

```
{pose}|{animations-list}
```

Configure a pose to play extra animations.

Example:
```
Drink|HandGripTightRight
```

### Full example

```
# by default, play those animations on all poses
DEFAULT 0|RestBentoHead
DEFAULT 1|CloseEyes;OpenHandRight;OpenHandLeft

# start seat0 (female) definitions
SITTER 0
# hold the glass on right hand
Drink|HandGripTightRight
# relaxed hands for female avatar
Cuddle1|HandRelaxRight;HandRelaxLeft

# start seat1 (male) definitions
SITTER 1
# splay right hand on the back of the female avatar
Cuddle1|HandleSplayRight
```

## Black Tulip converter

SecondLife has a similar plugin made by Black Tulip store. It uses a notecard named `[Black Tulip] Hand Poses - AVsitter Plugin ~CFG~`.

The `BTConfig2AVanim` script is a one-shot script converting this notecard to the `AVanim` notecard (in fact generating the later from the former, the original is untouched). Once the generation is completed, the script auto-deletes.

**Warning: this script uses notecard *OSSL* functions, so the owner of the object running the script must have those functions enabled: `osGetNotecard()` and `osMakeNotecard()`. This should be the case for all region owners.**

To use it, drop the script in a rezzed object containing the `[Black Tulip] Hand Poses - AVsitter Plugin ~CFG~` notecard. After a very short time, it will say in local chat that the generation is completed. It has then created the `AVanim` notecard and deleted itself.

You can then drop the `[AV]anim` script to enable the plugin.
