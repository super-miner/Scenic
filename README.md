# Scenes
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
5. Enable "Scenes" in `ProjectSettings > Plugins`.

## Asset Store Installation
1. Navigate to the `Asset Store` tab in your Godot project.
2. Locate the "Search" addon and click on it.
3. Click the download button.
4. Enable "Scenes" in `ProjectSettings > Plugins`.

# Setup
The Scenes addon works by completely circumventing the regular Godot scene system. Projects made with this addon will define one main scene containing the scene manager that will be loaded throughout the whole duration of the program.

It is recommended that the root node of this main scene is a `SceneManager`. The scene manager is responsible for managing things like loading and instantiating scenes as well as things like scene transitions.

[IMAGE HERE]

*A basic scene manager set-up with one transition. See [Transitions](https://github.com/super-miner/scene-manager-addon/README.md#transitions)  for more information about creating transitions.*

# Usage
The Scenes addon is designed to be as flexible as possible while keeping the core API simple. Because of this you may not need to read this whole section before you start using the addon. The features are ordered by how important they are to the average user.



## Transitions
