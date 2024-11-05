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

## Using Inpaint

1. Paint over the pearls and send to OpenCVInpaint 
2. Further refine the inpaint result 
3. Example using Flux.1-mask-inapint 

## Using Smudge

Simply smudge the pearls (a visual example here is also recommended).


