<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Based on https://wokwi.com/projects/392873974467527681
| **Physical Pin** | **Logic Label** | **Description** | 
|:----------------:|:---------------:|:-------:|
|   ui_in[7]       | Inverted Toggle |  0 = Auto Mode (1 Hz automatic scrolling)1 = Enables Manual Modes (Handled by Switch 4)  | 
|   ui_in[4]       | Button Step     |  Increments the character index ($+1$) with custom 50 ms heavy debouncing (Active only in Manual |Button Mode)|   
|   ui_in[5]       | Manual Sub-mode |  Active only when Switch 7 is 1.0 = Static Switch Mode (Uses Switches 3–0)1 = Manual Button Mode (Uses |Button 6)|
|   ui_in[3:0]     | Static Selection| Hexadecimal index inputs (0–15) to instantly pick specific characters when in Static Switch Mode|


On power-up, the 7-segment display should display the text PILIPINASLASALLE one at a time per clock cycle. 

Setting input pin 7 to HIGH enables manual override of the BCD value. In this mode, input pins 0-3 control the BCD value. The text displayed for each BCD value are tabulated below:
| **in0** | **in1** | **in2** | **in3** | **Character** |
|:-------:|:-------:|:-------:|:-------:|:-------------:|
|   LOW   |   LOW   |   LOW   |   LOW   |       P       |
|   LOW   |   LOW   |   LOW   |   HIGH  |       I       |
|   LOW   |   LOW   |   HIGH  |   LOW   |       L       |
|   LOW   |   LOW   |   HIGH  |   HIGH  |       I       |
|   LOW   |   HIGH  |   LOW   |   LOW   |       P       |
|   LOW   |   HIGH  |   LOW   |   HIGH  |       I       |
|   LOW   |   HIGH  |   HIGH  |   LOW   |       N       |
|   LOW   |   HIGH  |   HIGH  |   HIGH  |       A       |
|   HIGH  |   LOW   |   LOW   |   LOW   |       S       |
|   HIGH  |   LOW   |   LOW   |   HIGH  |       L       |
|   HIGH  |   LOW   |   HIGH  |   LOW   |       A       |
|   HIGH  |   LOW   |   HIGH  |   HIGH  |       S       |
|   HIGH  |   HIGH  |   LOW   |   LOW   |       A       |
|   HIGH  |   HIGH  |   LOW   |   HIGH  |       L       |
|   HIGH  |   HIGH  |   HIGH  |   LOW   |       L       |
|   HIGH  |   HIGH  |   HIGH  |   HIGH  |       E       |

## How to test

Default mode: Set the clock input to a low frequency such as 1 Hz to see the text transition per clock cycle.

Manual mode: Set the input pin 7 to HIGH and toggle input pins 0-3. The character displayed for each input combination should be according to the table above.

## External hardware

7-segment display
