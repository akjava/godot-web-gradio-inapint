The English could use some improvements for clarity and flow. Here's a revised version:

# Godot Web Gradio Inpaint

## What is this?

Gradio's Image Editor is often unreliable, and recently, Inpaint requires a guide image. This application allows you to create guide images and masks, then send them to inpainting Hugging Face Spaces like OpenCVInapint.  While it *could* technically access any API-enabled space, this tool is still in alpha and currently only connects to my own Hugging Face Space.

## Features

* Runs in a web browser (Godot web export)
* Simple pen drawing on images
* Simple mask drawing on images
* Simple smudge tool

## Limitations

* Does not work as a standalone app (no direct way to access Gradio)
* Inpainting is not performed within the app itself

## Known Bugs and To-Do

* No undo functionality
* No visual indication of pen size
* Smudge tool is unstable
* No way to connect to other Hugging Face Spaces/Gradio instances

# Basic Use Case: Removing Pearls

![image](https://github.com/user-attachments/assets/f460bb1f-62f4-4b15-a067-5473d552c2bb)

## Using Inpaint

1. Paint over the pearls and send to OpenCVInpaint
   
![image](https://github.com/user-attachments/assets/c82002a2-7e2a-4658-aeeb-3f9e11c81166)

2. Further refine the inpaint result

![image](https://github.com/user-attachments/assets/39879d04-33c2-451b-8267-5f1f5312d5df)
   
3. Example using Flux.1-mask-inapint

![image](https://github.com/user-attachments/assets/ccfeb158-7071-4976-bcc1-72e9dab889bc)

Erase neckless again...

## Using Smudge

Simply smudge the pearls ,maybe inpaint version help you

![image](https://github.com/user-attachments/assets/d795a8f5-9102-4537-9610-a202b0f1f24f)

## License
Codes are MIT License

Images are generated with <a href="https://huggingface.co/black-forest-labs/FLUX.1-schnell">FLUX.1-schnell</a> and licensed under <a href="http://www.apache.org/licenses/LICENSE-2.0">the Apache 2.0 License</a>

