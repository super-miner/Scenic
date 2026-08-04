# Scenic
A scene manager addon for Godot. Handles changing scenes, managing transitions, and asynchronous loading all with a simple but flexible API.

# Installation
You can install the addon manually or through the asset store.

> [!NOTE]
> If your version of Godot is not supported by the latest version of the addon you may need to download the addon manually so that you can pick an older version.

## Manual Installation
1. Download the addon from the GitHub Releases page.
2. Unzip the addon folder.
3. Create an `res://addons` folder in your Godot project if you do not already have one.
4. Drag the addon folder into your `res://addons` folder.
5. Enable "Scenic" in `Project Settings > Plugins`.

## Asset Store Installation
1. Navigate to the `Asset Store` tab in your Godot project.
2. Locate the "Search" addon and click on it.
3. Click the download button.
4. Enable "Scenic" in `Project Settings > Plugins`.

# Setup
Scenic works by completely circumventing the regular Godot scene system. Projects made with this addon will define one main scene containing the scene manager that will be loaded throughout the whole duration of the program.

It is recommended that the root node of your main scene is a `SceneManager`. The scene manager is responsible for managing things like loading and instantiating scenes as well as things like scene transitions.

## Creating the Main Scene
[IMAGE HERE]

*A basic scene manager set-up with one transition. See [Transitions](https://github.com/super-miner/scene-manager-addon/README.md#transitions)  for more information about creating transitions.*

Make sure your SceneManager node has `global` set to `true`. Scenic lets you use multiple scene managers but only one is allowed to be "global". The global scene can be accessed through the `GlobalSceneManager` autoload.

Once you have your main scene setup make sure to make it the default scene in `Project Settings > General > Application > Run > Main Scene`.

## Adding Scenes
You can add scenes to your scene manager by dragging them onto the scenes list in the inspector.

[IMAGE HERE]

From here you can set the properties of your scenes including:

* **Name:** The name of your scene. Used to reference the scene in code.
* **Initial:** Whether this scene is initial or not. Initial scenes are instantiated on project load.
* **Load on Start:** Whether this scene should load when the project starts. Scenes with this setting are kept in memory throughout the whole runtime of the program.

Set at least one scene to initial to get started.

# Usage
Scenic is designed to be as flexible as possible while keeping the core API simple. Because of this you may not need to read this whole section before you start using the addon. The features are ordered by how important they are to the average user.

## Changing Scenes

## Transitions

## Debugging
